from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List, Optional
from ..models.database import get_db
from ..models import models
from ..schemas import scrap_schemas
from ..utils.auth import get_current_user
import os
from datetime import datetime

router = APIRouter(
    prefix="/scraps",
    tags=["scraps"]
)

@router.post("/", response_model=scrap_schemas.Scrap)
async def create_scrap(
    scrap_in: scrap_schemas.ScrapCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """새로운 스크랩을 생성합니다."""
    # 논문 존재 확인
    paper = db.query(models.Paper).filter(models.Paper.id == scrap_in.paper_id).first()
    if not paper:
        raise HTTPException(status_code=404, detail="논문을 찾을 수 없습니다")

    # 스크랩 생성
    db_scrap = models.Scrap(
        **scrap_in.dict(),
        user_id=current_user.id
    )
    db.add(db_scrap)
    db.commit()
    db.refresh(db_scrap)
    return db_scrap

@router.get("/", response_model=List[scrap_schemas.Scrap])
async def read_scraps(
    paper_id: Optional[int] = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """사용자의 스크랩 목록을 가져옵니다."""
    query = db.query(models.Scrap).filter(models.Scrap.user_id == current_user.id)
    if paper_id:
        query = query.filter(models.Scrap.paper_id == paper_id)
    return query.offset(skip).limit(limit).all()

@router.put("/{scrap_id}", response_model=scrap_schemas.Scrap)
async def update_scrap(
    scrap_id: int,
    scrap_in: scrap_schemas.ScrapUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """스크랩을 수정합니다."""
    scrap = db.query(models.Scrap).filter(
        models.Scrap.id == scrap_id,
        models.Scrap.user_id == current_user.id
    ).first()
    
    if not scrap:
        raise HTTPException(status_code=404, detail="스크랩을 찾을 수 없습니다")

    for field, value in scrap_in.dict(exclude_unset=True).items():
        setattr(scrap, field, value)
    
    scrap.updated_at = datetime.utcnow()
    db.commit()
    db.refresh(scrap)
    return scrap

@router.delete("/{scrap_id}")
async def delete_scrap(
    scrap_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """스크랩을 삭제합니다."""
    scrap = db.query(models.Scrap).filter(
        models.Scrap.id == scrap_id,
        models.Scrap.user_id == current_user.id
    ).first()
    
    if not scrap:
        raise HTTPException(status_code=404, detail="스크랩을 찾을 수 없습니다")
    
    db.delete(scrap)
    db.commit()
    return {"message": "스크랩이 삭제되었습니다"} 