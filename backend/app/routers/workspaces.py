from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
from ..models.database import get_db
from ..models import models
from ..schemas import workspace_schemas, user_schemas
from ..utils.auth import get_current_user
import random
from datetime import datetime
from sqlalchemy import or_

router = APIRouter(
    prefix="/workspaces",
    tags=["workspaces"]
)

@router.get("/recommended", response_model=List[workspace_schemas.Workspace])
async def get_recommended_workspaces(
    research_field: Optional[str] = None,
    interests: Optional[List[str]] = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # 사용자가 팔로우하는 사람들의 ID 목록 가져오기
    following_ids = [f.following_id for f in current_user.following]
    
    # 사용자가 이미 가입한 워크스페이스 ID 목록 가져오기
    joined_workspace_ids = [
        member.workspace_id 
        for member in db.query(models.WorkspaceMember)
        .filter(models.WorkspaceMember.user_id == current_user.id)
        .all()
    ]
    
    # 가입하지 않은 public 워크스페이스만 필터링
    query = db.query(models.Workspace).filter(
        models.Workspace.is_public == True,
        ~models.Workspace.id.in_(joined_workspace_ids)  # 가입하지 않은 워크스페이스만
    )
    workspaces = query.all()
    scored_workspaces = []
    
    for workspace in workspaces:
        score = 0
        
        # 1. 팔로우한 사람이 워크스페이스 멤버인 경우 (가장 높은 가중치)
        workspace_member_ids = [member.user_id for member in workspace.members]
        following_members = set(following_ids) & set(workspace_member_ids)
        score += len(following_members) * 5  # 팔로우한 멤버 한 명당 5점
        
        # 2. 연구 분야 매칭
        if workspace.research_field == research_field:
            score += 3
        
        # 3. 관심사 매칭
        if interests:
            common_topics = set(workspace.research_topics) & set(interests)
            score += len(common_topics)
        
        # 4. 활성도 (멤버 수, 논문 수 등 고려)
        score += min(workspace.member_count // 5, 3)  # 최대 3점
        score += min(len(workspace.papers) // 3, 2)   # 최대 2점
        
        scored_workspaces.append((workspace, score))
    
    # 점수 기준으로 정렬
    scored_workspaces.sort(key=lambda x: x[1], reverse=True)
    
    # 상위 10개 중에서 랜덤으로 8개 선택
    top_ten = scored_workspaces[:10]
    if len(top_ten) > 8:
        selected_workspaces = random.sample(top_ten, 8)
        return [w[0] for w in selected_workspaces]
    
    return [w[0] for w in top_ten]

@router.post("/{workspace_id}/join")
async def join_workspace(
    workspace_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    try:
        # 워크스페이스 조회 시 관련 데이터도 함께 로드
        workspace = db.query(models.Workspace)\
            .options(
                joinedload(models.Workspace.members).joinedload(models.WorkspaceMember.user),
                joinedload(models.Workspace.papers).joinedload(models.WorkspacePaper.paper)
            )\
            .filter(models.Workspace.id == workspace_id)\
            .first()
            
        if not workspace:
            raise HTTPException(status_code=404, detail="Workspace not found")
            
        # 이미 멤버인지 확인
        existing_member = db.query(models.WorkspaceMember).filter(
            models.WorkspaceMember.workspace_id == workspace_id,
            models.WorkspaceMember.user_id == current_user.id
        ).first()
        
        if existing_member:
            raise HTTPException(status_code=400, detail="Already a member of this workspace")
        
        # 새 멤버 추가
        new_member = models.WorkspaceMember(
            workspace_id=workspace_id,
            user_id=current_user.id,
            role="member",
            joined_at=datetime.utcnow()
        )
        
        db.add(new_member)
        
        # 멤버 카운트 업데이트
        workspace.member_count += 1
        
        db.commit()
        
        # 워크스페이스 다시 로드
        workspace = db.query(models.Workspace)\
            .options(
                joinedload(models.Workspace.members).joinedload(models.WorkspaceMember.user),
                joinedload(models.Workspace.papers).joinedload(models.WorkspacePaper.paper)
            )\
            .filter(models.Workspace.id == workspace_id)\
            .first()
        
        # 업데이트된 워크스페이스 정보 반환
        return workspace_schemas.Workspace.from_orm(workspace)
        
    except Exception as e:
        db.rollback()
        import traceback
        print(f"Error in join_workspace: {str(e)}")
        print(traceback.format_exc())
        raise HTTPException(status_code=500, detail=f"Failed to join workspace: {str(e)}")

@router.get("/my", response_model=List[workspace_schemas.Workspace])
async def get_my_workspaces(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # 사용자가 가입한 워크스페이스 조회
    workspaces = db.query(models.Workspace)\
        .join(models.WorkspaceMember)\
        .options(
            joinedload(models.Workspace.members).joinedload(models.WorkspaceMember.user),
            joinedload(models.Workspace.papers).joinedload(models.WorkspacePaper.paper)
        )\
        .filter(models.WorkspaceMember.user_id == current_user.id)\
        .all()
    
    return workspaces

@router.get("/search", response_model=List[workspace_schemas.Workspace])
async def search_workspaces(
    query: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # ilike를 사용하여 대소문자 구분 없이 검색
    workspaces = db.query(models.Workspace)\
        .options(
            joinedload(models.Workspace.members).joinedload(models.WorkspaceMember.user),
            joinedload(models.Workspace.papers).joinedload(models.WorkspacePaper.paper)
        )\
        .filter(
            models.Workspace.is_public == True,
            or_(
                models.Workspace.name.ilike(f"%{query}%"),
                models.Workspace.description.ilike(f"%{query}%"),
                models.Workspace.research_field.ilike(f"%{query}%")
            )
        )\
        .all()
    
    return workspaces

@router.get("/users/search", response_model=List[user_schemas.User])
async def search_users(
    query: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    users = db.query(models.User)\
        .filter(
            or_(
                models.User.full_name.ilike(f"%{query}%"),
                models.User.institution.ilike(f"%{query}%"),
                models.User.department.ilike(f"%{query}%"),
                models.User.research_field.ilike(f"%{query}%")
            )
        )\
        .all()
    
    return users 