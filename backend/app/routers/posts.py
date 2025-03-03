from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional

from ..utils.auth import get_current_user
from ..models.database import get_db
from ..models.models import User
from ..schemas.post_schemas import Post, PostDetail, PostCreate, PostUpdate, PostComment, PostCommentCreate
from ..services.post_service import PostService

router = APIRouter(
    prefix="/posts",
    tags=["posts"],
    responses={404: {"description": "Not found"}},
)

@router.post("/", response_model=Post, status_code=status.HTTP_201_CREATED)
def create_post(
    post: PostCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """새 포스트를 생성합니다."""
    return PostService.create_post(db=db, post=post, user_id=current_user.id)

@router.get("/", response_model=List[PostDetail])
def get_posts(
    skip: int = 0,
    limit: int = 100,
    user_id: Optional[int] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트 목록을 조회합니다. user_id가 제공되면 해당 사용자의 포스트만 조회합니다."""
    if user_id:
        return PostService.get_posts_by_user(db=db, user_id=user_id, skip=skip, limit=limit)
    else:
        # 모든 포스트 조회 로직 (필요시 구현)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="사용자 ID를 지정해주세요."
        )

@router.get("/feed", response_model=List[PostDetail])
def get_feed_posts(
    skip: Optional[int] = Query(0, ge=0),
    limit: Optional[int] = Query(20, ge=1, le=100),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """팔로우하는 사용자들의 포스트를 조회합니다."""
    return PostService.get_feed_posts(db=db, user_id=current_user.id, skip=skip, limit=limit)

@router.get("/{post_id}", response_model=PostDetail)
def get_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """특정 포스트를 조회합니다."""
    post = PostService.get_post(db=db, post_id=post_id)
    if post is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="포스트를 찾을 수 없습니다."
        )
    
    # 포스트 상세 정보 조회 로직 (작성자 정보, 좋아요/저장 수 등)
    author = db.query(User).filter(User.id == post.author_id).first()
    
    # 포스트 상세 정보 반환
    return {
        **post.__dict__,
        "author_name": author.full_name if author else "Unknown",
        "author_profile_image": author.profile_image_url,
        # 추가 정보는 서비스에서 계산
    }

@router.put("/{post_id}", response_model=Post)
def update_post(
    post_id: int,
    post_update: PostUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트를 업데이트합니다."""
    updated_post = PostService.update_post(
        db=db, post_id=post_id, post_update=post_update, user_id=current_user.id
    )
    if updated_post is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="포스트를 찾을 수 없거나 수정 권한이 없습니다."
        )
    return updated_post

@router.delete("/{post_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트를 삭제합니다."""
    success = PostService.delete_post(db=db, post_id=post_id, user_id=current_user.id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="포스트를 찾을 수 없거나 삭제 권한이 없습니다."
        )
    return {"detail": "포스트가 삭제되었습니다."}

@router.post("/{post_id}/like", status_code=status.HTTP_201_CREATED)
def like_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트에 좋아요를 추가합니다."""
    post = PostService.get_post(db=db, post_id=post_id)
    if post is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="포스트를 찾을 수 없습니다."
        )
    
    like = PostService.like_post(db=db, post_id=post_id, user_id=current_user.id)
    return {"detail": "포스트에 좋아요를 추가했습니다."}

@router.delete("/{post_id}/like", status_code=status.HTTP_204_NO_CONTENT)
def unlike_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트 좋아요를 취소합니다."""
    success = PostService.unlike_post(db=db, post_id=post_id, user_id=current_user.id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="좋아요를 찾을 수 없습니다."
        )
    return {"detail": "포스트 좋아요를 취소했습니다."}

@router.post("/{post_id}/save", status_code=status.HTTP_201_CREATED)
def save_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트를 저장합니다."""
    post = PostService.get_post(db=db, post_id=post_id)
    if post is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="포스트를 찾을 수 없습니다."
        )
    
    save = PostService.save_post(db=db, post_id=post_id, user_id=current_user.id)
    return {"detail": "포스트를 저장했습니다."}

@router.delete("/{post_id}/save", status_code=status.HTTP_204_NO_CONTENT)
def unsave_post(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트 저장을 취소합니다."""
    success = PostService.unsave_post(db=db, post_id=post_id, user_id=current_user.id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="저장된 포스트를 찾을 수 없습니다."
        )
    return {"detail": "포스트 저장을 취소했습니다."}

@router.post("/{post_id}/comments", response_model=PostComment, status_code=status.HTTP_201_CREATED)
def add_comment(
    post_id: int,
    comment: PostCommentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트에 댓글을 추가합니다."""
    post = PostService.get_post(db=db, post_id=post_id)
    if post is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="포스트를 찾을 수 없습니다."
        )
    
    # 부모 댓글이 있는 경우 존재 여부 확인
    if comment.parent_id:
        parent_comment = db.query(PostComment).filter(PostComment.id == comment.parent_id).first()
        if not parent_comment or parent_comment.post_id != post_id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="유효하지 않은 부모 댓글입니다."
            )
    
    return PostService.add_comment(
        db=db, 
        post_id=post_id, 
        user_id=current_user.id, 
        content=comment.content, 
        parent_id=comment.parent_id
    )

@router.get("/{post_id}/comments", response_model=List[PostComment])
def get_comments(
    post_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """포스트의 댓글을 조회합니다."""
    post = PostService.get_post(db=db, post_id=post_id)
    if post is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="포스트를 찾을 수 없습니다."
        )
    
    return PostService.get_comments(db=db, post_id=post_id) 