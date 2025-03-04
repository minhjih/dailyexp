from sqlalchemy.orm import Session
from sqlalchemy import func, desc
from typing import List, Optional
from datetime import datetime

from ..models.models import Post, PostLike, PostSave, PostComment, User, Follow
from ..schemas.post_schemas import PostCreate, PostUpdate

class PostService:
    @staticmethod
    def create_post(db: Session, post: PostCreate, user_id: int) -> Post:
        """새 포스트를 생성합니다."""
        db_post = Post(
            title=post.title,
            content=post.content,
            paper_title=post.paper_title,
            key_insights=post.key_insights,
            paper_id=post.paper_id,
            author_id=user_id
        )
        db.add(db_post)
        db.commit()
        db.refresh(db_post)
        return db_post
    
    @staticmethod
    def get_post(db: Session, post_id: int) -> Optional[Post]:
        """ID로 포스트를 조회합니다."""
        return db.query(Post).filter(Post.id == post_id).first()
    
    @staticmethod
    def get_posts_by_user(db: Session, user_id: int, skip: int = 0, limit: int = 100) -> List[dict]:
        """특정 사용자의 포스트를 조회합니다."""
        posts = db.query(Post).filter(Post.author_id == user_id).order_by(desc(Post.created_at)).offset(skip).limit(limit).all()
        
        # 포스트 작성자 정보 추가
        result = []
        for post in posts:
            author = db.query(User).filter(User.id == post.author_id).first()
            
            # 좋아요, 저장, 댓글 수 계산
            like_count = db.query(func.count(PostLike.id)).filter(PostLike.post_id == post.id).scalar()
            save_count = db.query(func.count(PostSave.id)).filter(PostSave.post_id == post.id).scalar()
            comment_count = db.query(func.count(PostComment.id)).filter(PostComment.post_id == post.id).scalar()
            
            # 현재 사용자가 좋아요/저장했는지 확인
            is_liked = db.query(PostLike).filter(PostLike.post_id == post.id, PostLike.user_id == user_id).first() is not None
            is_saved = db.query(PostSave).filter(PostSave.post_id == post.id, PostSave.user_id == user_id).first() is not None
            
            post_dict = {
                "id": post.id,
                "title": post.title,
                "content": post.content,
                "paper_title": post.paper_title,
                "key_insights": post.key_insights,
                "created_at": post.created_at,
                "updated_at": post.updated_at,
                "author_id": post.author_id,
                "paper_id": post.paper_id,
                "author_name": author.full_name if author else "Unknown",
                "author_profile_image": author.profile_image_url if author else None,
                "like_count": like_count,
                "save_count": save_count,
                "comment_count": comment_count,
                "is_liked": is_liked,
                "is_saved": is_saved
            }
            result.append(post_dict)
        
        return result
    
    @staticmethod
    def get_feed_posts(db: Session, user_id: int, skip: int = 0, limit: int = 20) -> List[dict]:
        """사용자가 팔로우하는 사용자들의 포스트를 조회합니다."""
        # 사용자가 팔로우하는 사용자 ID 목록 조회
        following_ids = db.query(Follow.following_id).filter(Follow.follower_id == user_id).all()
        following_ids = [id[0] for id in following_ids]
        
        # 팔로우하는 사용자들의 포스트 조회
        posts = db.query(Post).filter(Post.author_id.in_(following_ids)).order_by(desc(Post.created_at)).offset(skip).limit(limit).all()
        
        # 포스트 작성자 정보 추가
        result = []
        for post in posts:
            author = db.query(User).filter(User.id == post.author_id).first()
            
            # 좋아요, 저장, 댓글 수 계산
            like_count = db.query(func.count(PostLike.id)).filter(PostLike.post_id == post.id).scalar()
            save_count = db.query(func.count(PostSave.id)).filter(PostSave.post_id == post.id).scalar()
            comment_count = db.query(func.count(PostComment.id)).filter(PostComment.post_id == post.id).scalar()
            
            # 현재 사용자가 좋아요/저장했는지 확인
            is_liked = db.query(PostLike).filter(PostLike.post_id == post.id, PostLike.user_id == user_id).first() is not None
            is_saved = db.query(PostSave).filter(PostSave.post_id == post.id, PostSave.user_id == user_id).first() is not None
            
            post_dict = {
                "id": post.id,
                "title": post.title,
                "content": post.content,
                "paper_title": post.paper_title,
                "key_insights": post.key_insights,
                "created_at": post.created_at,
                "updated_at": post.updated_at,
                "author_id": post.author_id,
                "paper_id": post.paper_id,
                "author_name": author.full_name if author else "Unknown",
                "author_profile_image": author.profile_image_url if author else None,
                "like_count": like_count,
                "save_count": save_count,
                "comment_count": comment_count,
                "is_liked": is_liked,
                "is_saved": is_saved
            }
            result.append(post_dict)
        
        return result
    
    @staticmethod
    def update_post(db: Session, post_id: int, post_update: PostUpdate, user_id: int) -> Optional[Post]:
        """포스트를 업데이트합니다."""
        db_post = db.query(Post).filter(Post.id == post_id, Post.author_id == user_id).first()
        if not db_post:
            return None
        
        update_data = post_update.dict(exclude_unset=True)
        for key, value in update_data.items():
            setattr(db_post, key, value)
        
        db_post.updated_at = datetime.utcnow()
        db.commit()
        db.refresh(db_post)
        return db_post
    
    @staticmethod
    def delete_post(db: Session, post_id: int, user_id: int) -> bool:
        """포스트를 삭제합니다."""
        db_post = db.query(Post).filter(Post.id == post_id, Post.author_id == user_id).first()
        if not db_post:
            return False
        
        db.delete(db_post)
        db.commit()
        return True
    
    @staticmethod
    def like_post(db: Session, post_id: int, user_id: int) -> PostLike:
        """포스트에 좋아요를 추가합니다."""
        # 이미 좋아요한 경우 확인
        existing_like = db.query(PostLike).filter(
            PostLike.post_id == post_id,
            PostLike.user_id == user_id
        ).first()
        
        if existing_like:
            return existing_like
        
        # 새 좋아요 생성
        new_like = PostLike(post_id=post_id, user_id=user_id)
        db.add(new_like)
        db.commit()
        db.refresh(new_like)
        return new_like
    
    @staticmethod
    def unlike_post(db: Session, post_id: int, user_id: int) -> bool:
        """포스트 좋아요를 취소합니다."""
        like = db.query(PostLike).filter(
            PostLike.post_id == post_id,
            PostLike.user_id == user_id
        ).first()
        
        if not like:
            return False
        
        db.delete(like)
        db.commit()
        return True
    
    @staticmethod
    def save_post(db: Session, post_id: int, user_id: int) -> PostSave:
        """포스트를 저장합니다."""
        # 이미 저장한 경우 확인
        existing_save = db.query(PostSave).filter(
            PostSave.post_id == post_id,
            PostSave.user_id == user_id
        ).first()
        
        if existing_save:
            return existing_save
        
        # 새 저장 생성
        new_save = PostSave(post_id=post_id, user_id=user_id)
        db.add(new_save)
        db.commit()
        db.refresh(new_save)
        return new_save
    
    @staticmethod
    def unsave_post(db: Session, post_id: int, user_id: int) -> bool:
        """포스트 저장을 취소합니다."""
        save = db.query(PostSave).filter(
            PostSave.post_id == post_id,
            PostSave.user_id == user_id
        ).first()
        
        if not save:
            return False
        
        db.delete(save)
        db.commit()
        return True
    
    @staticmethod
    def add_comment(db: Session, post_id: int, user_id: int, content: str, parent_id: Optional[int] = None) -> PostComment:
        """포스트에 댓글을 추가합니다."""
        comment = PostComment(
            content=content,
            post_id=post_id,
            user_id=user_id,
            parent_id=parent_id
        )
        db.add(comment)
        db.commit()
        db.refresh(comment)
        return comment
    
    @staticmethod
    def get_comments(db: Session, post_id: int) -> List[PostComment]:
        """포스트의 댓글을 조회합니다."""
        return db.query(PostComment).filter(
            PostComment.post_id == post_id,
            PostComment.parent_id.is_(None)  # 최상위 댓글만 조회
        ).order_by(PostComment.created_at).all() 