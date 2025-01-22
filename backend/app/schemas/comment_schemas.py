from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class CommentBase(BaseModel):
    content: str
    target_type: str
    target_id: int
    parent_id: Optional[int] = None

class CommentCreate(CommentBase):
    pass

class CommentUpdate(BaseModel):
    content: str

class Comment(CommentBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    replies: List['Comment'] = []

    class Config:
        orm_mode = True 