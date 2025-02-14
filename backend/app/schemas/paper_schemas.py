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

class Paper(BaseModel):
    id: int
    title: str
    authors: List[str]  # 문자열 리스트로 변경
    abstract: str
    published_date: str
    arxiv_id: str
    url: str
    categories: List[str]
    created_at: datetime
    updated_at: datetime
    user_id: Optional[int] = None

    class Config:
        from_attributes = True

class PaperInWorkspace(BaseModel):
    id: int
    paper_id: int
    added_at: datetime
    status: str
    paper: Paper

    class Config:
        from_attributes = True 