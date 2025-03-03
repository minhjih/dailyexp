from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text, JSON, Boolean, ARRAY
from sqlalchemy.orm import relationship, backref
from .database import Base
from datetime import datetime

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    full_name = Column(String)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # 추가되는 필드들
    institution = Column(String, nullable=True)  # 소속 기관/학교
    department = Column(String, nullable=True)  # 학과/부서
    research_field = Column(String, nullable=True)  # 주 연구 분야
    research_interests = Column(ARRAY(String), nullable=True)  # 관심 연구 주제들
    bio = Column(String, nullable=True)  # 한줄 소개
    external_links = Column(JSON, nullable=True)  # 외부 링크들 (GitHub, LinkedIn 등)
    profile_image_url = Column(String, nullable=True)  # 프로필 이미지
    
    papers = relationship("Paper", back_populates="user")
    scraps = relationship("Scrap", back_populates="user")
    tags = relationship("Tag", back_populates="user")
    owned_groups = relationship("Group", back_populates="owner")
    group_memberships = relationship("GroupMember", back_populates="user")
    comments = relationship("Comment", back_populates="user")
    owned_workspaces = relationship("Workspace", back_populates="owner")
    workspace_memberships = relationship("WorkspaceMember", back_populates="user")
    posts = relationship("Post", back_populates="author")
    post_likes = relationship("PostLike", back_populates="user")
    post_saves = relationship("PostSave", back_populates="user")

class Paper(Base):
    __tablename__ = "papers"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    authors = Column(ARRAY(String))
    abstract = Column(Text)
    published_date = Column(String)
    arxiv_id = Column(String, unique=True)
    url = Column(String)
    categories = Column(ARRAY(String))
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    user_id = Column(Integer, ForeignKey("users.id"))

    # Relationships
    user = relationship("User", back_populates="papers")
    workspace_papers = relationship("WorkspacePaper", back_populates="paper")
    scraps = relationship("Scrap", back_populates="paper")
    group_shares = relationship("GroupSharedPaper", back_populates="paper")
    posts = relationship("Post", foreign_keys="Post.paper_id", back_populates="paper")

class Post(Base):
    __tablename__ = "posts"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    content = Column(Text)
    paper_title = Column(String, nullable=True)
    key_insights = Column(ARRAY(String), nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    author_id = Column(Integer, ForeignKey("users.id"))
    paper_id = Column(Integer, ForeignKey("papers.id"), nullable=True)

    author = relationship("User", back_populates="posts")
    paper = relationship("Paper", foreign_keys=[paper_id], back_populates="posts")
    likes = relationship("PostLike", back_populates="post", cascade="all, delete-orphan")
    saves = relationship("PostSave", back_populates="post", cascade="all, delete-orphan")
    comments = relationship("PostComment", back_populates="post", cascade="all, delete-orphan")

class PostLike(Base):
    __tablename__ = "post_likes"

    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("posts.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

    post = relationship("Post", back_populates="likes")
    user = relationship("User", back_populates="post_likes")

class PostSave(Base):
    __tablename__ = "post_saves"

    id = Column(Integer, primary_key=True, index=True)
    post_id = Column(Integer, ForeignKey("posts.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

    post = relationship("Post", back_populates="saves")
    user = relationship("User", back_populates="post_saves")

class PostComment(Base):
    __tablename__ = "post_comments"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text)
    post_id = Column(Integer, ForeignKey("posts.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 대댓글을 위한 필드
    parent_id = Column(Integer, ForeignKey("post_comments.id"), nullable=True)
    
    post = relationship("Post", back_populates="comments")
    user = relationship("User")
    replies = relationship("PostComment", backref=backref("parent", remote_side=[id]))

class Scrap(Base):
    __tablename__ = "scraps"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text)  # 텍스트 내용
    image_url = Column(String)  # 이미지 URL 저장
    scrap_type = Column(String)  # 'text' 또는 'image'
    note = Column(Text)  # 사용자의 메모
    page_number = Column(Integer, nullable=True)  # 논문의 페이지 번호
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    is_public = Column(Boolean, default=False)  # 공개 여부
    search_vector = Column(Text)  # 검색을 위한 필드
    
    user_id = Column(Integer, ForeignKey("users.id"))
    paper_id = Column(Integer, ForeignKey("papers.id"))
    
    user = relationship("User", back_populates="scraps")
    paper = relationship("Paper", back_populates="scraps")
    tags = relationship("ScrapTag", back_populates="scrap")
    shares = relationship("SharedScrap", back_populates="scrap")
    group_shares = relationship("GroupSharedScrap", back_populates="scrap")

class Tag(Base):
    __tablename__ = "tags"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    user_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

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
    shared_at = Column(DateTime, default=datetime.utcnow)
    
    scrap = relationship("Scrap", back_populates="shares")
    shared_with_user = relationship("User")

class Group(Base):
    __tablename__ = "groups"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    description = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    owner_id = Column(Integer, ForeignKey("users.id"))
    
    owner = relationship("User", back_populates="owned_groups")
    members = relationship("GroupMember", back_populates="group")
    shared_papers = relationship("GroupSharedPaper", back_populates="group")
    shared_scraps = relationship("GroupSharedScrap", back_populates="group")

class GroupMember(Base):
    __tablename__ = "group_members"

    id = Column(Integer, primary_key=True, index=True)
    group_id = Column(Integer, ForeignKey("groups.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    role = Column(String)  # 'admin' 또는 'member'
    joined_at = Column(DateTime, default=datetime.utcnow)
    
    group = relationship("Group", back_populates="members")
    user = relationship("User", back_populates="group_memberships")

class GroupSharedPaper(Base):
    __tablename__ = "group_shared_papers"

    id = Column(Integer, primary_key=True, index=True)
    paper_id = Column(Integer, ForeignKey("papers.id"))
    group_id = Column(Integer, ForeignKey("groups.id"))
    shared_by_id = Column(Integer, ForeignKey("users.id"))
    shared_at = Column(DateTime, default=datetime.utcnow)
    note = Column(Text, nullable=True)
    
    paper = relationship("Paper", back_populates="group_shares")
    group = relationship("Group", back_populates="shared_papers")
    shared_by = relationship("User")

class GroupSharedScrap(Base):
    __tablename__ = "group_shared_scraps"

    id = Column(Integer, primary_key=True, index=True)
    scrap_id = Column(Integer, ForeignKey("scraps.id"))
    group_id = Column(Integer, ForeignKey("groups.id"))
    shared_by_id = Column(Integer, ForeignKey("users.id"))
    shared_at = Column(DateTime, default=datetime.utcnow)
    note = Column(Text, nullable=True)
    
    scrap = relationship("Scrap", back_populates="group_shares")
    group = relationship("Group", back_populates="shared_scraps")
    shared_by = relationship("User")

class Comment(Base):
    __tablename__ = "comments"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(Text)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # 댓글 작성자
    user_id = Column(Integer, ForeignKey("users.id"))
    user = relationship("User", back_populates="comments")
    
    # 댓글이 달린 대상 (논문/스크랩/그룹 공유)
    target_type = Column(String)  # 'paper', 'scrap', 'group_paper', 'group_scrap'
    target_id = Column(Integer)
    
    # 대댓글을 위한 필드
    parent_id = Column(Integer, ForeignKey("comments.id"), nullable=True)
    replies = relationship("Comment", backref=backref("parent", remote_side=[id]))

class Follow(Base):
    __tablename__ = "follows"

    id = Column(Integer, primary_key=True, index=True)
    follower_id = Column(Integer, ForeignKey("users.id"))
    following_id = Column(Integer, ForeignKey("users.id"))
    created_at = Column(DateTime, default=datetime.utcnow)

    # 관계 설정
    follower = relationship("User", foreign_keys=[follower_id], backref="following")
    following = relationship("User", foreign_keys=[following_id], backref="followers")

class Workspace(Base):
    __tablename__ = "workspaces"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String)
    description = Column(Text)
    research_field = Column(String)
    research_topics = Column(ARRAY(String))
    owner_id = Column(Integer, ForeignKey("users.id"))
    is_public = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    member_count = Column(Integer, default=1)
    
    owner = relationship("User", back_populates="owned_workspaces")
    members = relationship("WorkspaceMember", back_populates="workspace")
    papers = relationship("WorkspacePaper", back_populates="workspace")

class WorkspaceMember(Base):
    __tablename__ = "workspace_members"

    id = Column(Integer, primary_key=True, index=True)
    workspace_id = Column(Integer, ForeignKey("workspaces.id"))
    user_id = Column(Integer, ForeignKey("users.id"))
    role = Column(String, default="member")  # admin or member
    joined_at = Column(DateTime, default=datetime.utcnow)

    workspace = relationship("Workspace", back_populates="members")
    user = relationship("User", back_populates="workspace_memberships")

class WorkspacePaper(Base):
    __tablename__ = "workspace_papers"

    id = Column(Integer, primary_key=True, index=True)
    workspace_id = Column(Integer, ForeignKey("workspaces.id"))
    paper_id = Column(Integer, ForeignKey("papers.id"))
    added_by = Column(Integer, ForeignKey("users.id"))
    added_at = Column(DateTime, default=datetime.utcnow)
    status = Column(String, default="in_progress")  # in_progress, completed, archived

    workspace = relationship("Workspace", back_populates="papers")
    paper = relationship("Paper")
    added_by_user = relationship("User") 