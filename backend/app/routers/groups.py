from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from ..models.database import get_db
from ..models import models
from ..schemas import group_schemas
from ..utils.auth import get_current_user

router = APIRouter(
    prefix="/groups",
    tags=["groups"]
)

@router.post("/", response_model=group_schemas.Group)
async def create_group(
    group_in: group_schemas.GroupCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """새로운 그룹을 생성합니다."""
    db_group = models.Group(**group_in.dict(), owner_id=current_user.id)
    db.add(db_group)
    db.commit()
    db.refresh(db_group)
    
    # 그룹 생성자를 admin으로 추가
    member = models.GroupMember(
        group_id=db_group.id,
        user_id=current_user.id,
        role="admin"
    )
    db.add(member)
    db.commit()
    
    return db_group

@router.get("/", response_model=List[group_schemas.Group])
async def get_my_groups(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """사용자가 속한 모든 그룹을 조회합니다."""
    return db.query(models.Group).join(
        models.GroupMember
    ).filter(
        models.GroupMember.user_id == current_user.id
    ).all()

@router.post("/{group_id}/members", response_model=group_schemas.GroupMember)
async def add_group_member(
    group_id: int,
    member_in: group_schemas.GroupMemberCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """그룹에 새 멤버를 추가합니다."""
    # 권한 확인
    member = db.query(models.GroupMember).filter(
        models.GroupMember.group_id == group_id,
        models.GroupMember.user_id == current_user.id,
        models.GroupMember.role == "admin"
    ).first()
    
    if not member:
        raise HTTPException(
            status_code=403,
            detail="그룹 관리자만 멤버를 추가할 수 있습니다"
        )
    
    new_member = models.GroupMember(
        group_id=group_id,
        **member_in.dict()
    )
    db.add(new_member)
    db.commit()
    db.refresh(new_member)
    return new_member

@router.post("/{group_id}/papers", response_model=group_schemas.Group)
async def share_paper_with_group(
    group_id: int,
    share_in: group_schemas.GroupPaperShare,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """논문을 그룹과 공유합니다."""
    # 그룹 멤버 확인
    member = db.query(models.GroupMember).filter(
        models.GroupMember.group_id == group_id,
        models.GroupMember.user_id == current_user.id
    ).first()
    
    if not member:
        raise HTTPException(
            status_code=403,
            detail="그룹 멤버만 논문을 공유할 수 있습니다"
        )
    
    shared_paper = models.GroupSharedPaper(
        group_id=group_id,
        paper_id=share_in.paper_id,
        shared_by_id=current_user.id,
        note=share_in.note
    )
    db.add(shared_paper)
    db.commit()
    
    return db.query(models.Group).filter(models.Group.id == group_id).first()

@router.post("/{group_id}/scraps", response_model=group_schemas.Group)
async def share_scrap_with_group(
    group_id: int,
    share_in: group_schemas.GroupScrapShare,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """스크랩을 그룹과 공유합니다."""
    # 그룹 멤버 확인
    member = db.query(models.GroupMember).filter(
        models.GroupMember.group_id == group_id,
        models.GroupMember.user_id == current_user.id
    ).first()
    
    if not member:
        raise HTTPException(
            status_code=403,
            detail="그룹 멤버만 스크랩을 공유할 수 있습니다"
        )
    
    shared_scrap = models.GroupSharedScrap(
        group_id=group_id,
        scrap_id=share_in.scrap_id,
        shared_by_id=current_user.id,
        note=share_in.note
    )
    db.add(shared_scrap)
    db.commit()
    
    return db.query(models.Group).filter(models.Group.id == group_id).first()

@router.get("/{group_id}/papers", response_model=List[dict])
async def get_group_papers(
    group_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """그룹에 공유된 논문들을 조회합니다."""
    # 그룹 멤버 확인
    member = db.query(models.GroupMember).filter(
        models.GroupMember.group_id == group_id,
        models.GroupMember.user_id == current_user.id
    ).first()
    
    if not member:
        raise HTTPException(
            status_code=403,
            detail="그룹 멤버만 공유된 논문을 볼 수 있습니다"
        )
    
    shared_papers = db.query(models.GroupSharedPaper).filter(
        models.GroupSharedPaper.group_id == group_id
    ).all()
    
    return shared_papers

@router.get("/{group_id}/scraps", response_model=List[dict])
async def get_group_scraps(
    group_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """그룹에 공유된 스크랩들을 조회합니다."""
    # 그룹 멤버 확인
    member = db.query(models.GroupMember).filter(
        models.GroupMember.group_id == group_id,
        models.GroupMember.user_id == current_user.id
    ).first()
    
    if not member:
        raise HTTPException(
            status_code=403,
            detail="그룹 멤버만 공유된 스크랩을 볼 수 있습니다"
        )
    
    shared_scraps = db.query(models.GroupSharedScrap).filter(
        models.GroupSharedScrap.group_id == group_id
    ).all()
    
    return shared_scraps 