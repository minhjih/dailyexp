from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class Author(BaseModel):
    name: str
    affiliation: Optional[List[str]] = []

class PaperBase(BaseModel):
    title: str
    abstract: Optional[str] = None
    authors: List[Author]
    published_date: Optional[datetime] = None
    doi: Optional[str] = None
    publisher: Optional[str] = None
    publication_title: Optional[str] = None

class PaperCreate(PaperBase):
    ieee_id: str

class Paper(PaperBase):
    id: int
    ieee_id: str
    user_id: Optional[int] = None
    ai_summary: Optional[str] = None

    class Config:
        orm_mode = True 