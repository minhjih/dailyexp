from pydantic import BaseModel, Field
from typing import List, Optional, Dict
from datetime import datetime

# 포스트 댓글 스키마
class PostCommentBase(BaseModel):
    content: str

class PostCommentCreate(PostCommentBase):
    post_id: int
    parent_id: Optional[int] = None

class PostComment(PostCommentBase):
    id: int
    post_id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    parent_id: Optional[int] = None
    user_name: Optional[str] = None
    user_profile_image: Optional[str] = None
    
    class Config:
        orm_mode = True

# 포스트 스키마
class PostBase(BaseModel):
    title: str
    content: str
    paper_title: Optional[str] = None
    key_insights: Optional[List[str]] = None
    paper_id: Optional[int] = None

class PostCreate(PostBase):
    pass

class PostUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None
    paper_title: Optional[str] = None
    key_insights: Optional[List[str]] = None
    paper_id: Optional[int] = None

class Post(PostBase):
    id: int
    author_id: int
    created_at: datetime
    updated_at: datetime
    
    class Config:
        orm_mode = True

class PostDetail(Post):
    author_name: Optional[str] = None
    author_profile_image: Optional[str] = None
    like_count: int = 0
    save_count: int = 0
    comment_count: int = 0
    is_liked: bool = False
    is_saved: bool = False
    
    class Config:
        orm_mode = True

# 포스트 좋아요 스키마
class PostLikeCreate(BaseModel):
    post_id: int

class PostLike(BaseModel):
    id: int
    post_id: int
    user_id: int
    created_at: datetime
    
    class Config:
        orm_mode = True

# 포스트 저장 스키마
class PostSaveCreate(BaseModel):
    post_id: int

class PostSave(BaseModel):
    id: int
    post_id: int
    user_id: int
    created_at: datetime
    
    class Config:
        orm_mode = True 