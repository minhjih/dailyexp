from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from .user_schemas import User
from .paper_schemas import Paper

class WorkspaceMemberBase(BaseModel):
    id: int
    user_id: int
    role: str
    joined_at: datetime
    user: User

    class Config:
        orm_mode = True

class WorkspacePaperBase(BaseModel):
    id: int
    paper_id: int
    added_at: datetime
    status: str
    paper: Paper

    class Config:
        orm_mode = True

class WorkspaceBase(BaseModel):
    name: str
    description: str
    research_field: str
    research_topics: List[str]
    is_public: bool = True

class WorkspaceCreate(WorkspaceBase):
    pass

class Workspace(WorkspaceBase):
    id: int
    owner_id: int
    created_at: datetime
    updated_at: datetime
    member_count: int = 1
    members: List[WorkspaceMemberBase]
    papers: List[WorkspacePaperBase]

    class Config:
        orm_mode = True 