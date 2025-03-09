from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..models.database import get_db
from ..models import models
from ..schemas import user_schemas
from ..utils.auth import get_current_user
from sqlalchemy import or_

router = APIRouter(
    prefix="/users",
    tags=["users"]
)

@router.get("/search", response_model=List[user_schemas.User])
async def search_users(
    query: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """
    사용자 검색 엔드포인트
    이름, 소속, 부서, 연구 분야로 사용자를 검색합니다.
    """
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