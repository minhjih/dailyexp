from pydantic import BaseModel
from typing import Optional
from datetime import datetime

class ScrapBase(BaseModel):
    content: Optional[str] = None
    image_url: Optional[str] = None
    scrap_type: str  # 'text' 또는 'image'
    note: Optional[str] = None
    page_number: Optional[int] = None

class ScrapCreate(ScrapBase):
    paper_id: int

class ScrapUpdate(ScrapBase):
    pass

class Scrap(ScrapBase):
    id: int
    user_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        orm_mode = True 