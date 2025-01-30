from pydantic import BaseModel, EmailStr
from typing import Optional, List, Dict
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    full_name: str

class UserCreate(BaseModel):
    email: EmailStr
    password: str
    full_name: str
    institution: str
    department: str
    research_field: str
    research_interests: List[str]
    bio: Optional[str] = None
    external_links: Optional[Dict[str, str]] = None

class User(BaseModel):
    id: int
    email: EmailStr
    full_name: str
    institution: str
    department: str
    research_field: str
    research_interests: List[str]
    bio: Optional[str]
    external_links: Optional[Dict[str, str]]
    profile_image_url: Optional[str]
    created_at: datetime

    class Config:
        orm_mode = True

class Token(BaseModel):
    access_token: str
    token_type: str

class TokenData(BaseModel):
    email: Optional[str] = None

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    institution: Optional[str] = None
    department: Optional[str] = None
    research_field: Optional[str] = None
    research_interests: Optional[List[str]] = None
    bio: Optional[str] = None
    external_links: Optional[Dict[str, str]] = None 