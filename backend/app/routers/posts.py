from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import List, Optional
from sqlalchemy.sql import desc, func

from ..utils.auth import get_current_user
from ..models.database import get_db
from ..models.models import User, Post as PostModel, PostLike, PostSave, PostComment
from ..schemas.post_schemas import Post, PostDetail, PostCreate, PostUpdate, PostComment as PostCommentSchema, PostCommentCreate
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
        # 직접 PostDetail 객체를 생성하여 반환
        from ..schemas.post_schemas import PostDetail
        
        posts = db.query(PostModel).filter(PostModel.author_id == user_id).order_by(desc(PostModel.created_at)).offset(skip).limit(limit).all()
        
        # 포스트 작성자 정보 추가
        result = []
        for post in posts:
            author = db.query(User).filter(User.id == post.author_id).first()
            
            # 좋아요, 저장, 댓글 수 계산
            like_count = db.query(func.count(PostLike.id)).filter(PostLike.post_id == post.id).scalar()
            save_count = db.query(func.count(PostSave.id)).filter(PostSave.post_id == post.id).scalar()
            comment_count = db.query(func.count(PostComment.id)).filter(PostComment.post_id == post.id).scalar()
            
            # 현재 사용자가 좋아요/저장했는지 확인
            is_liked = db.query(PostLike).filter(PostLike.post_id == post.id, PostLike.user_id == current_user.id).first() is not None
            is_saved = db.query(PostSave).filter(PostSave.post_id == post.id, PostSave.user_id == current_user.id).first() is not None
            
            # PostDetail 객체 생성
            post_detail = PostDetail(
                id=post.id,
                title=post.title,
                content=post.content,
                paper_title=post.paper_title,
                key_insights=post.key_insights,
                created_at=post.created_at,
                updated_at=post.updated_at,
                author_id=post.author_id,
                paper_id=post.paper_id,
                author_name=author.full_name if author else "Unknown",
                author_profile_image=author.profile_image_url,
                like_count=like_count,
                save_count=save_count,
                comment_count=comment_count,
                is_liked=is_liked,
                is_saved=is_saved
            )
            result.append(post_detail)
        
        return result
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

@router.post("/{post_id}/comments", response_model=PostCommentSchema, status_code=status.HTTP_201_CREATED)
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
    
    new_comment = PostService.add_comment(
        db=db, 
        post_id=post_id, 
        user_id=current_user.id, 
        content=comment.content, 
        parent_id=comment.parent_id
    )
    
    # 댓글 작성자 정보 추가
    new_comment.user_name = current_user.full_name
    new_comment.user_profile_image = current_user.profile_image_url
    
    return new_comment

@router.get("/{post_id}/comments", response_model=List[PostCommentSchema])
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
    
    comments = PostService.get_comments(db=db, post_id=post_id)
    
    # 댓글 작성자 정보 추가
    for comment in comments:
        user = db.query(User).filter(User.id == comment.user_id).first()
        if user:
            comment.user_name = user.full_name
            comment.user_profile_image = user.profile_image_url
    
    return comments 