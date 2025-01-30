from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://user:password@db/dailyexp")

engine = create_engine(DATABASE_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def init_db():
    # 여기서 models를 import
    from . import models
    from ..utils.auth import get_password_hash
    import datetime
    
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    
    db = SessionLocal()
    
    # 초기 사용자 데이터 생성
    test_users = [
        {
            "email": "user1@test.com",
            "full_name": "Sarah Chen",
            "institution": "MIT",
            "department": "Computer Science",
            "research_field": "AI Healthcare",
            "research_interests": ["AI", "Healthcare", "Machine Learning"],
            "bio": "Researching AI applications in healthcare",
        },
        {
            "email": "user2@test.com",
            "full_name": "John Smith",
            "institution": "Stanford",
            "department": "Physics",
            "research_field": "Quantum Computing",
            "research_interests": ["Quantum", "Computing", "Physics"],
            "bio": "Quantum computing researcher",
        },
        {
            "email": "user3@test.com",
            "full_name": "Emily Wang",
            "institution": "Harvard",
            "department": "Biology",
            "research_field": "Genetics",
            "research_interests": ["Genetics", "Molecular Biology"],
            "bio": "Studying genetic variations",
        },
        {
            "email": "user4@test.com",
            "full_name": "Michael Brown",
            "institution": "Berkeley",
            "department": "Chemistry",
            "research_field": "Materials Science",
            "research_interests": ["Materials", "Nanotechnology"],
            "bio": "Developing new materials",
        },
        {
            "email": "user5@test.com",
            "full_name": "Lisa Kim",
            "institution": "Caltech",
            "department": "Engineering",
            "research_field": "Robotics",
            "research_interests": ["Robotics", "AI", "Control Systems"],
            "bio": "Working on autonomous robots",
        },
        {
            "email": "user6@test.com",
            "full_name": "David Lee",
            "institution": "Princeton",
            "department": "Mathematics",
            "research_field": "Data Science",
            "research_interests": ["Data Science", "Statistics"],
            "bio": "Exploring data patterns",
        },
        {
            "email": "user7@test.com",
            "full_name": "Anna Martinez",
            "institution": "Yale",
            "department": "Neuroscience",
            "research_field": "Brain Mapping",
            "research_interests": ["Neuroscience", "Brain", "Cognitive Science"],
            "bio": "Studying brain patterns",
        },
        {
            "email": "user8@test.com",
            "full_name": "James Wilson",
            "institution": "Columbia",
            "department": "Environmental Science",
            "research_field": "Climate Change",
            "research_interests": ["Climate", "Environment", "Sustainability"],
            "bio": "Researching climate impacts",
        },
        {
            "email": "user9@test.com",
            "full_name": "Sophie Taylor",
            "institution": "Oxford",
            "department": "Psychology",
            "research_field": "Behavioral Science",
            "research_interests": ["Psychology", "Behavior", "Social Science"],
            "bio": "Understanding human behavior",
        },
        {
            "email": "user10@test.com",
            "full_name": "Robert Garcia",
            "institution": "Cambridge",
            "department": "Economics",
            "research_field": "Financial Technology",
            "research_interests": ["Economics", "Finance", "Technology"],
            "bio": "Studying financial systems",
        },
    ]

    try:
        for user_data in test_users:
            user = models.User(
                email=user_data["email"],
                hashed_password=get_password_hash("admin"),
                full_name=user_data["full_name"],
                institution=user_data["institution"],
                department=user_data["department"],
                research_field=user_data["research_field"],
                research_interests=user_data["research_interests"],
                bio=user_data["bio"],
                created_at=datetime.datetime.utcnow()
            )
            db.add(user)
        
        db.commit()
    except Exception as e:
        print(f"Error creating test users: {e}")
        db.rollback()
    finally:
        db.close()