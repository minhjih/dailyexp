from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime

class GroupBase(BaseModel):
    name: str
    description: Optional[str] = None

class GroupCreate(GroupBase):
    pass

class GroupUpdate(GroupBase):
    pass

class GroupMemberBase(BaseModel):
    role: str = "member"  # 'admin' 또는 'member'

class GroupMemberCreate(GroupMemberBase):
    user_id: int

class GroupMember(GroupMemberBase):
    id: int
    group_id: int
    user_id: int
    joined_at: datetime

    class Config:
        orm_mode = True

class Group(GroupBase):
    id: int
    owner_id: int
    created_at: datetime
    members: List[GroupMember] = []

    class Config:
        orm_mode = True

class GroupShareBase(BaseModel):
    note: Optional[str] = None

class GroupPaperShare(GroupShareBase):
    paper_id: int

class GroupScrapShare(GroupShareBase):
    scrap_id: int 