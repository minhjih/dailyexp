from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from ..models.database import get_db
from ..models import models
from ..schemas import user_schemas
from ..utils.auth import get_current_user

router = APIRouter(
    prefix="/profile",
    tags=["profile"]
)

@router.get("/me", response_model=user_schemas.User)
async def get_my_profile(
    current_user: models.User = Depends(get_current_user)
):
    """현재 로그인한 사용자의 프로필 정보를 반환합니다."""
    return current_user

@router.get("/{user_id}", response_model=user_schemas.User)
async def get_user_profile(
    user_id: int,
    db: Session = Depends(get_db)
):
    """특정 사용자의 프로필 정보를 반환합니다."""
    user = db.query(models.User).filter(models.User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.put("/me", response_model=user_schemas.User)
async def update_my_profile(
    profile_update: user_schemas.UserUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """현재 로그인한 사용자의 프로필 정보를 수정합니다."""
    for field, value in profile_update.dict(exclude_unset=True).items():
        setattr(current_user, field, value)
    
    db.commit()
    db.refresh(current_user)
    return current_user 