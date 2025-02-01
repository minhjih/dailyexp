from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..models.database import get_db
from ..models import models
from ..schemas import workspace_schemas
from ..utils.auth import get_current_user
import random

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
    
    query = db.query(models.Workspace).filter(models.Workspace.is_public == True)
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