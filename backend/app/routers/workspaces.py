from fastapi import APIRouter, Depends, HTTPException, Body
from sqlalchemy.orm import Session, joinedload
from typing import List, Optional
from ..models.database import get_db
from ..models import models
from ..schemas import workspace_schemas, user_schemas
from ..utils.auth import get_current_user
import random
from datetime import datetime
from sqlalchemy import or_
from pydantic import BaseModel

router = APIRouter(
    prefix="/workspaces",
    tags=["workspaces"]
)

class PaperData(BaseModel):
    title: str
    authors: list
    summary: str
    published_date: str
    arxiv_id: str
    url: str
    categories: list

class WorkspaceCreate(BaseModel):
    name: str
    description: str
    research_field: str
    research_topics: List[str]
    is_public: bool
    creator_role: str = "maintainer"  # 기본값은 maintainer
    members: List[dict] = []

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
    try:
        workspaces = (
            db.query(models.Workspace)
            .join(
                models.WorkspaceMember,
                models.Workspace.id == models.WorkspaceMember.workspace_id
            )
            .filter(models.WorkspaceMember.user_id == current_user.id)
            .options(
                joinedload(models.Workspace.owner),
                joinedload(models.Workspace.members).joinedload(models.WorkspaceMember.user),
                joinedload(models.Workspace.papers).joinedload(models.WorkspacePaper.paper)
            )
            .all()
        )

        # 상세 디버그 로그
        print("\n=== Workspace Data Debug ===")
        for ws in workspaces:
            print(f"\nWorkspace ID: {ws.id}")
            print(f"Name: {ws.name}")
            print(f"Owner ID: {ws.owner_id}")
            print(f"Owner Name: {ws.owner.full_name if ws.owner else 'None'}")
            print(f"Member Count: {ws.member_count}")
            print("Members:")
            for member in ws.members:
                print(f"  - User ID: {member.user_id}, Name: {member.user.full_name}, Role: {member.role}")
            print("Papers:")
            for paper in ws.papers:
                print(f"  - Paper ID: {paper.paper_id}, Title: {paper.paper.title}")
            print("Raw Data:")
            print(workspace_schemas.Workspace.from_orm(ws).dict())
            print("========================\n")

        return workspaces

    except Exception as e:
        print(f"Error getting workspaces: {e}")
        db.rollback()
        raise HTTPException(status_code=500, detail=str(e))

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

@router.post("/{workspace_id}/papers")
async def add_paper_to_workspace(
    workspace_id: int,
    paper_data: PaperData,  # 타입 명시
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    try:
        workspace = db.query(models.Workspace).filter(models.Workspace.id == workspace_id).first()
        if not workspace:
            raise HTTPException(status_code=404, detail="Workspace not found")
        
        # 워크스페이스 멤버인지 확인
        member = db.query(models.WorkspaceMember).filter(
            models.WorkspaceMember.workspace_id == workspace_id,
            models.WorkspaceMember.user_id == current_user.id
        ).first()
        if not member:
            raise HTTPException(status_code=403, detail="Not a member of this workspace")

        # 논문이 이미 존재하는지 확인
        existing_paper = db.query(models.Paper).filter(
            models.Paper.arxiv_id == paper_data.arxiv_id
        ).first()

        if not existing_paper:
            # 새 논문 생성
            paper = models.Paper(
                title=paper_data.title,
                authors=paper_data.authors,
                abstract=paper_data.summary,
                published_date=paper_data.published_date,
                arxiv_id=paper_data.arxiv_id,
                url=paper_data.url,
                categories=paper_data.categories
            )
            db.add(paper)
            db.flush()
        else:
            paper = existing_paper

        # 이미 워크스페이스에 추가된 논문인지 확인
        existing_workspace_paper = db.query(models.WorkspacePaper).filter(
            models.WorkspacePaper.workspace_id == workspace_id,
            models.WorkspacePaper.paper_id == paper.id
        ).first()

        if existing_workspace_paper:
            return {"message": "Paper already exists in workspace"}

        # 워크스페이스에 논문 추가
        workspace_paper = models.WorkspacePaper(
            workspace_id=workspace_id,
            paper_id=paper.id,
            added_by=current_user.id,
            status='active'
        )
        db.add(workspace_paper)
        db.commit()

        return {"message": "Paper added to workspace successfully"}
        
    except Exception as e:
        db.rollback()
        print(f"Error adding paper to workspace: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{workspace_id}", response_model=workspace_schemas.Workspace)
async def get_workspace(
    workspace_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    try:
        # 워크스페이스와 관련 데이터를 함께 로드
        workspace = (
            db.query(models.Workspace)
            .options(
                joinedload(models.Workspace.owner),
                joinedload(models.Workspace.members).joinedload(models.WorkspaceMember.user),
                joinedload(models.Workspace.papers).joinedload(models.WorkspacePaper.paper)
            )
            .filter(models.Workspace.id == workspace_id)
            .first()
        )

        if not workspace:
            raise HTTPException(status_code=404, detail="Workspace not found")

        # 멤버 수 업데이트
        member_count = len(workspace.members)
        if workspace.member_count != member_count:
            workspace.member_count = member_count
            db.commit()

        # 각 멤버의 owner 여부 설정
        for member in workspace.members:
            member.is_owner = (member.user_id == workspace.owner_id)

        return workspace

    except Exception as e:
        print(f"Error getting workspace: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{workspace_id}/papers")
async def get_workspace_papers(
    workspace_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    try:
        # 워크스페이스 존재 확인
        workspace = db.query(models.Workspace).filter(models.Workspace.id == workspace_id).first()
        if not workspace:
            raise HTTPException(status_code=404, detail="Workspace not found")
        
        # 워크스페이스 멤버인지 확인
        member = db.query(models.WorkspaceMember).filter(
            models.WorkspaceMember.workspace_id == workspace_id,
            models.WorkspaceMember.user_id == current_user.id
        ).first()
        if not member:
            raise HTTPException(status_code=403, detail="Not a member of this workspace")

        # 워크스페이스의 논문 목록 조회 (Paper 정보 포함)
        workspace_papers = (
            db.query(models.WorkspacePaper)
            .filter(models.WorkspacePaper.workspace_id == workspace_id)
            .join(models.Paper)
            .options(joinedload(models.WorkspacePaper.paper))  # Paper 정보를 함께 로드
            .all()
        )

        # 응답 데이터 구조화
        return [
            {
                "id": wp.id,
                "paper_id": wp.paper_id,
                "added_at": wp.added_at,
                "status": wp.status,
                "paper": {
                    "id": wp.paper.id,
                    "title": wp.paper.title,
                    "authors": wp.paper.authors,
                    "abstract": wp.paper.abstract,
                    "published_date": wp.paper.published_date,
                    "arxiv_id": wp.paper.arxiv_id,
                    "url": wp.paper.url,
                    "categories": wp.paper.categories,
                    "created_at": wp.paper.created_at,
                    "updated_at": wp.paper.updated_at,
                    "user_id": wp.paper.user_id
                }
            }
            for wp in workspace_papers
        ]

    except Exception as e:
        print(f"Error getting workspace papers: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/new", response_model=workspace_schemas.Workspace)
async def create_new_workspace(
    workspace_data: WorkspaceCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    워크스페이스 생성 엔드포인트
    생성자의 역할을 지정할 수 있으며, 다른 멤버도 초대할 수 있습니다.
    """
    try:
        # 워크스페이스 생성
        new_workspace = models.Workspace(
            name=workspace_data.name,
            description=workspace_data.description,
            research_field=workspace_data.research_field,
            research_topics=workspace_data.research_topics,
            is_public=workspace_data.is_public,
            owner_id=current_user.id,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow(),
            member_count=1 + len(workspace_data.members)  # 생성자 + 초대된 멤버
        )
        
        db.add(new_workspace)
        db.flush()  # ID 생성을 위해 flush
        
        # 생성자를 멤버로 추가
        creator_member = models.WorkspaceMember(
            workspace_id=new_workspace.id,
            user_id=current_user.id,
            role=workspace_data.creator_role,  # 생성자 역할 설정
            joined_at=datetime.utcnow()
        )
        db.add(creator_member)
        
        # 초대된 멤버 추가
        for member_data in workspace_data.members:
            # 사용자 존재 확인
            user_id = member_data.get('user_id')
            user = db.query(models.User).filter(models.User.id == user_id).first()
            if not user:
                continue  # 사용자가 없으면 건너뜀
                
            # 이미 멤버인지 확인 (중복 방지)
            if user_id == current_user.id:
                continue  # 생성자는 이미 추가됨
                
            # 멤버 추가
            member = models.WorkspaceMember(
                workspace_id=new_workspace.id,
                user_id=user_id,
                role=member_data.get('role', 'member'),  # 기본 역할은 member
                joined_at=datetime.utcnow()
            )
            db.add(member)
        
        db.commit()
        
        # 생성된 워크스페이스 조회 (관련 데이터 포함)
        created_workspace = (
            db.query(models.Workspace)
            .options(
                joinedload(models.Workspace.owner),
                joinedload(models.Workspace.members).joinedload(models.WorkspaceMember.user)
            )
            .filter(models.Workspace.id == new_workspace.id)
            .first()
        )
        
        return created_workspace
        
    except Exception as e:
        db.rollback()
        print(f"Error creating workspace: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to create workspace: {str(e)}") 