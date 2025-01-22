from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.orm import Session
from typing import List, Optional
from ..models.database import get_db
from ..models import models
from ..schemas import scrap_schemas
from ..utils.auth import get_current_user
import os
from datetime import datetime
from sqlalchemy import or_, text

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

@router.post("/tags", response_model=scrap_schemas.Tag)
async def create_tag(
    tag: scrap_schemas.TagCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """새로운 태그를 생성합니다."""
    db_tag = models.Tag(name=tag.name, user_id=current_user.id)
    db.add(db_tag)
    db.commit()
    db.refresh(db_tag)
    return db_tag

@router.get("/tags", response_model=List[scrap_schemas.Tag])
async def get_tags(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """사용자의 모든 태그를 조회합니다."""
    return db.query(models.Tag).filter(models.Tag.user_id == current_user.id).all()

@router.post("/{scrap_id}/share", response_model=scrap_schemas.Scrap)
async def share_scrap(
    scrap_id: int,
    share_data: scrap_schemas.SharedScrapCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """스크랩을 다른 사용자와 공유합니다."""
    scrap = db.query(models.Scrap).filter(
        models.Scrap.id == scrap_id,
        models.Scrap.user_id == current_user.id
    ).first()
    
    if not scrap:
        raise HTTPException(status_code=404, detail="스크랩을 찾을 수 없습니다")
        
    shared_scrap = models.SharedScrap(
        scrap_id=scrap_id,
        shared_with_user_id=share_data.shared_with_user_id
    )
    db.add(shared_scrap)
    db.commit()
    return scrap

@router.get("/shared", response_model=List[scrap_schemas.Scrap])
async def get_shared_scraps(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """나와 공유된 스크랩들을 조회합니다."""
    return db.query(models.Scrap).join(
        models.SharedScrap
    ).filter(
        models.SharedScrap.shared_with_user_id == current_user.id
    ).all()

@router.get("/search", response_model=List[scrap_schemas.Scrap])
async def search_scraps(
    query: str,
    tag_ids: Optional[List[int]] = None,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """스크랩을 검색합니다."""
    search_query = db.query(models.Scrap).filter(
        models.Scrap.user_id == current_user.id
    )
    
    # 텍스트 검색
    if query:
        search_query = search_query.filter(
            or_(
                models.Scrap.content.ilike(f"%{query}%"),
                models.Scrap.note.ilike(f"%{query}%")
            )
        )
    
    # 태그 필터링
    if tag_ids:
        search_query = search_query.join(
            models.ScrapTag
        ).filter(
            models.ScrapTag.tag_id.in_(tag_ids)
        )
    
    return search_query.all() 