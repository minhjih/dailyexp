from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text, JSON, Boolean
from sqlalchemy.orm import relationship
from .database import Base
import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    full_name = Column(String)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    papers = relationship("Paper", back_populates="user")
    scraps = relationship("Scrap", back_populates="user")
    tags = relationship("Tag", back_populates="user")

class Paper(Base):
    __tablename__ = "papers"

    id = Column(Integer, primary_key=True, index=True)
    ieee_id = Column(String, unique=True, index=True)
    title = Column(String)
    abstract = Column(Text)
    authors = Column(JSON)
    published_date = Column(DateTime)
    ai_summary = Column(JSON)
    core_claims = Column(Text)
    methodology = Column(Text)
    key_findings = Column(Text)
    visual_elements = Column(JSON)
    future_research = Column(Text)
    user_id = Column(Integer, ForeignKey("users.id"))
    
    user = relationship("User", back_populates="papers")
    scraps = relationship("Scrap", back_populates="paper")

class Scrap(Base):
    __tablename__ = "scraps"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text)  # 텍스트 내용
    image_url = Column(String)  # 이미지 URL 저장
    scrap_type = Column(String)  # 'text' 또는 'image'
    note = Column(Text)  # 사용자의 메모
    page_number = Column(Integer, nullable=True)  # 논문의 페이지 번호
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.datetime.utcnow, onupdate=datetime.datetime.utcnow)
    is_public = Column(Boolean, default=False)  # 공개 여부
    search_vector = Column(Text)  # 검색을 위한 필드
    
    user_id = Column(Integer, ForeignKey("users.id"))
    paper_id = Column(Integer, ForeignKey("papers.id"))
    
    user = relationship("User", back_populates="scraps")
    paper = relationship("Paper", back_populates="scraps")
    tags = relationship("ScrapTag", back_populates="scrap")
    shares = relationship("SharedScrap", back_populates="scrap")

class Tag(Base):
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    user = relationship("User", back_populates="tags")
    scraps = relationship("ScrapTag", back_populates="tag")

class ScrapTag(Base):
    __tablename__ = "scrap_tags"

    scrap_id = Column(Integer, ForeignKey("scraps.id"), primary_key=True)
    tag_id = Column(Integer, ForeignKey("tags.id"), primary_key=True)
    
    scrap = relationship("Scrap", back_populates="tags")
    tag = relationship("Tag", back_populates="scraps")

class SharedScrap(Base):
    __tablename__ = "shared_scraps"

    id = Column(Integer, primary_key=True, index=True)
    scrap_id = Column(Integer, ForeignKey("scraps.id"))
    shared_with_user_id = Column(Integer, ForeignKey("users.id"))
    shared_at = Column(DateTime, default=datetime.datetime.utcnow)
    
    scrap = relationship("Scrap", back_populates="shares")
    shared_with_user = relationship("User") 