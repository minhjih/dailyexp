from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from typing import List, Optional
from ..models.database import get_db
from ..models import models
from ..schemas import comment_schemas
from ..utils.auth import get_current_user

router = APIRouter(
    prefix="/comments",
    tags=["comments"]
)

@router.post("/", response_model=comment_schemas.Comment)
async def create_comment(
    comment_in: comment_schemas.CommentCreate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """새로운 댓글을 작성합니다."""
    # 대상 존재 확인
    if not check_target_exists(db, comment_in.target_type, comment_in.target_id):
        raise HTTPException(status_code=404, detail="댓글을 달 대상을 찾을 수 없습니다")
    
    # 부모 댓글 확인 (대댓글인 경우)
    if comment_in.parent_id:
        parent = db.query(models.Comment).filter(models.Comment.id == comment_in.parent_id).first()
        if not parent:
            raise HTTPException(status_code=404, detail="부모 댓글을 찾을 수 없습니다")

    db_comment = models.Comment(
        **comment_in.dict(),
        user_id=current_user.id
    )
    db.add(db_comment)
    db.commit()
    db.refresh(db_comment)
    return db_comment

@router.get("/target/{target_type}/{target_id}", response_model=List[comment_schemas.Comment])
async def get_comments(
    target_type: str,
    target_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """특정 대상의 댓글들을 조회합니다."""
    comments = db.query(models.Comment).filter(
        models.Comment.target_type == target_type,
        models.Comment.target_id == target_id,
        models.Comment.parent_id == None  # 최상위 댓글만 가져옴
    ).all()
    return comments

@router.put("/{comment_id}", response_model=comment_schemas.Comment)
async def update_comment(
    comment_id: int,
    comment_in: comment_schemas.CommentUpdate,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """댓글을 수정합니다."""
    comment = db.query(models.Comment).filter(
        models.Comment.id == comment_id,
        models.Comment.user_id == current_user.id
    ).first()
    
    if not comment:
        raise HTTPException(status_code=404, detail="댓글을 찾을 수 없거나 수정 권한이 없습니다")
    
    comment.content = comment_in.content
    db.commit()
    db.refresh(comment)
    return comment

@router.delete("/{comment_id}")
async def delete_comment(
    comment_id: int,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    """댓글을 삭제합니다."""
    comment = db.query(models.Comment).filter(
        models.Comment.id == comment_id,
        models.Comment.user_id == current_user.id
    ).first()
    
    if not comment:
        raise HTTPException(status_code=404, detail="댓글을 찾을 수 없거나 삭제 권한이 없습니다")
    
    db.delete(comment)
    db.commit()
    return {"message": "댓글이 삭제되었습니다"}

def check_target_exists(db: Session, target_type: str, target_id: int) -> bool:
    """댓글 대상이 존재하는지 확인합니다."""
    if target_type == "paper":
        return db.query(models.Paper).filter(models.Paper.id == target_id).first() is not None
    elif target_type == "scrap":
        return db.query(models.Scrap).filter(models.Scrap.id == target_id).first() is not None
    elif target_type == "group_paper":
        return db.query(models.GroupSharedPaper).filter(models.GroupSharedPaper.id == target_id).first() is not None
    elif target_type == "group_scrap":
        return db.query(models.GroupSharedScrap).filter(models.GroupSharedScrap.id == target_id).first() is not None
    return False 