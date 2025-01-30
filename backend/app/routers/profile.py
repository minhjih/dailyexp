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

@router.get("/me/stats", response_model=dict)
async def get_profile_stats(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """현재 사용자의 팔로워/팔로잉 수를 반환합니다."""
    followers_count = db.query(models.Follow).filter(
        models.Follow.following_id == current_user.id
    ).count()
    
    following_count = db.query(models.Follow).filter(
        models.Follow.follower_id == current_user.id
    ).count()
    
    return {
        "followers_count": followers_count,
        "following_count": following_count
    }

@router.post("/{user_id}/follow")
async def follow_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """다른 사용자를 팔로우합니다."""
    if user_id == current_user.id:
        raise HTTPException(status_code=400, detail="자기 자신을 팔로우할 수 없습니다")
        
    follow = models.Follow(
        follower_id=current_user.id,
        following_id=user_id
    )
    db.add(follow)
    db.commit()
    return {"message": "Successfully followed"}

@router.delete("/{user_id}/follow")
async def unfollow_user(
    user_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """팔로우를 취소합니다."""
    follow = db.query(models.Follow).filter(
        models.Follow.follower_id == current_user.id,
        models.Follow.following_id == user_id
    ).first()
    
    if follow:
        db.delete(follow)
        db.commit()
    return {"message": "Successfully unfollowed"}

@router.get("/me/following")
async def get_following(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """현재 사용자가 팔로우하는 사용자 목록을 반환합니다."""
    following = db.query(models.User).join(
        models.Follow,
        models.Follow.following_id == models.User.id
    ).filter(
        models.Follow.follower_id == current_user.id
    ).all()
    
    return following or []  # 팔로잉이 없으면 빈 리스트 반환 