from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

class TagBase(BaseModel):
    name: str

class TagCreate(TagBase):
    pass

class Tag(TagBase):
    id: int
    user_id: int
    created_at: datetime

    class Config:
        orm_mode = True

class ScrapBase(BaseModel):
    content: Optional[str] = None
    image_url: Optional[str] = None
    scrap_type: str  # 'text' 또는 'image'
    note: Optional[str] = None
    page_number: Optional[int] = None
    is_public: bool = False
    tag_ids: Optional[List[int]] = []

class ScrapCreate(ScrapBase):
    paper_id: int

class ScrapUpdate(ScrapBase):
    pass

class SharedScrapCreate(BaseModel):
    shared_with_user_id: int

class Scrap(ScrapBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime
    tags: List[Tag] = []
    shared_with: List[int] = []

    class Config:
        orm_mode = True 