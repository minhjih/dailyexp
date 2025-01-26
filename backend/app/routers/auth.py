from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from datetime import timedelta
from typing import Any
from ..models.database import get_db
from ..models import models
from ..schemas import user_schemas
from ..utils.auth import (
    verify_password,
    create_access_token,
    get_password_hash,
    ACCESS_TOKEN_EXPIRE_MINUTES,
    get_current_user
)
import logging

router = APIRouter(
    prefix="/auth",
    tags=["authentication"]
)

logger = logging.getLogger(__name__)

@router.post("/signup", response_model=user_schemas.User)
async def signup(
    user: user_schemas.UserCreate,
    db: Session = Depends(get_db)
):
    try:
        logger.info(f"Signup attempt for email: {user.email}")
        
        # 이메일 중복 체크
        db_user = db.query(models.User).filter(
            models.User.email == user.email
        ).first()
        
        if db_user:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="이미 등록된 이메일입니다"
            )
        
        # 새 사용자 생성
        hashed_password = get_password_hash(user.password)
        
        db_user = models.User(
            email=user.email,
            hashed_password=hashed_password,
            full_name=user.full_name,
            institution=user.institution,
            department=user.department,
            research_field=user.research_field,
            research_interests=user.research_interests,
            bio=user.bio,
            external_links=user.external_links or {}
        )
        
        logger.info(f"Creating new user: {db_user.email}")
        
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        
        logger.info(f"Successfully created user: {db_user.email}")
        return db_user
        
    except HTTPException as he:
        logger.error(f"HTTP Exception during signup: {str(he)}")
        raise he
    except Exception as e:
        logger.error(f"Error during signup: {str(e)}")
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"회원가입 처리 중 오류가 발생했습니다: {str(e)}"
        )

@router.post("/login", response_model=user_schemas.Token)
def login(
    form_data: OAuth2PasswordRequestForm = Depends(),
    db: Session = Depends(get_db)
) -> Any:
    """사용자 로그인을 처리합니다."""
    # 사용자 확인
    user = db.query(models.User).filter(models.User.email == form_data.username).first()
    if not user or not verify_password(form_data.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="이메일 또는 비밀번호가 올바르지 않습니다",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # 액세스 토큰 생성
    access_token_expires = timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    access_token = create_access_token(
        data={"sub": user.email}, expires_delta=access_token_expires
    )
    return {"access_token": access_token, "token_type": "bearer"}

@router.get("/me", response_model=user_schemas.User)
async def read_users_me(
    current_user: models.User = Depends(get_current_user)
):
    """현재 로그인한 사용자의 정보를 반환합니다."""
    return current_user 