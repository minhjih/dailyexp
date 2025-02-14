from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from .user_schemas import User
from .paper_schemas import Paper, PaperInWorkspace

class WorkspaceMember(BaseModel):
    id: int
    user_id: int
    role: str
    joined_at: datetime
    user: User
    is_owner: bool = False

    class Config:
        from_attributes = True

class WorkspacePaperBase(BaseModel):
    id: int
    paper_id: int
    added_at: datetime
    status: str
    paper: Paper

    class Config:
        from_attributes = True

class WorkspaceBase(BaseModel):
    name: str
    description: str
    research_field: str
    research_topics: List[str]
    is_public: bool = True

class WorkspaceCreate(WorkspaceBase):
    pass

class Workspace(BaseModel):
    id: int
    name: str
    description: str
    research_field: str
    research_topics: List[str]
    owner_id: int
    owner: User
    is_public: bool = True
    created_at: datetime
    updated_at: datetime
    member_count: int = 1
    members: List[WorkspaceMember]
    papers: List[PaperInWorkspace]

    class Config:
        from_attributes = True 