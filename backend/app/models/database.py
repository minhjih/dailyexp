from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
import os
import datetime
from passlib.context import CryptContext
import random

load_dotenv()

# 비밀번호 해싱을 위한 설정
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

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
    # 여기서 모든 모델을 import
    from .models import (
        User, Follow, Paper, Comment, Group, 
        Workspace, WorkspaceMember, WorkspacePaper,  # WorkspacePaper 추가
        Scrap, Tag, ScrapTag, SharedScrap,          # 관련 모델들도 추가
        GroupSharedPaper, GroupSharedScrap
    )
    
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
            user = User(
                email=user_data["email"],
                hashed_password=pwd_context.hash("admin"),  # 직접 비밀번호 해싱
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

    # 워크스페이스 샘플 데이터
    workspaces = [
        {
            "name": "AI Healthcare Research Group",
            "description": "AI 기술을 활용한 의료 진단 및 치료 방법 연구",
            "research_field": "AI Healthcare",
            "research_topics": ["Medical Imaging", "Disease Prediction", "Healthcare AI"],
            "owner_id": 1
        },
        {
            "name": "Quantum Computing Lab",
            "description": "양자 컴퓨팅 알고리즘 및 응용 연구",
            "research_field": "Quantum Computing",
            "research_topics": ["Quantum Algorithms", "Quantum Error Correction"],
            "owner_id": 2
        },
        {
            "name": "Brain Mapping Initiative",
            "description": "뇌 구조와 기능의 매핑 연구",
            "research_field": "Brain Mapping",
            "research_topics": ["Neuroscience", "Brain", "Cognitive Science"],
            "owner_id": 7
        },
        {
            "name": "Climate Change Research Network",
            "description": "기후 변화 영향 및 대응 전략 연구",
            "research_field": "Climate Change",
            "research_topics": ["Climate", "Environment", "Sustainability"],
            "owner_id": 8
        },
        {
            "name": "Behavioral Economics Group",
            "description": "행동 경제학 이론 및 실험 연구",
            "research_field": "Behavioral Science",
            "research_topics": ["Psychology", "Economics", "Decision Making"],
            "owner_id": 9
        },
        {
            "name": "Genetics Data Analysis Group",
            "description": "유전체 데이터 분석 및 질병 연관성 연구",
            "research_field": "Genetics",
            "research_topics": ["Genomics", "Bioinformatics", "Disease Genetics"],
            "owner_id": 3
        },
        {
            "name": "Advanced Materials Lab",
            "description": "신소재 개발 및 특성 분석 연구",
            "research_field": "Materials Science",
            "research_topics": ["Nanomaterials", "Material Characterization"],
            "owner_id": 4
        },
        {
            "name": "Robotics Innovation Center",
            "description": "로봇 시스템 설계 및 제어 연구",
            "research_field": "Robotics",
            "research_topics": ["Robot Control", "AI", "Automation"],
            "owner_id": 5
        },
        {
            "name": "Data Mining Research Group",
            "description": "대규모 데이터 분석 및 패턴 발견",
            "research_field": "Data Science",
            "research_topics": ["Data Mining", "Machine Learning", "Big Data"],
            "owner_id": 6
        },
        {
            "name": "FinTech Innovation Lab",
            "description": "금융 기술 혁신 및 응용 연구",
            "research_field": "Financial Technology",
            "research_topics": ["Blockchain", "Digital Finance", "Risk Analysis"],
            "owner_id": 10
        },
        {
            "name": "AI Drug Discovery",
            "description": "AI 기반 신약 개발 연구",
            "research_field": "AI Healthcare",
            "research_topics": ["Drug Discovery", "Molecular Modeling", "AI"],
            "owner_id": 1
        },
        {
            "name": "Quantum Information Lab",
            "description": "양자 정보 이론 및 암호화 연구",
            "research_field": "Quantum Computing",
            "research_topics": ["Quantum Information", "Cryptography"],
            "owner_id": 2
        },
        {
            "name": "Molecular Genetics Lab",
            "description": "분자 유전학 메커니즘 연구",
            "research_field": "Genetics",
            "research_topics": ["Molecular Biology", "Gene Expression"],
            "owner_id": 3
        },
        {
            "name": "Smart Materials Group",
            "description": "지능형 소재 개발 연구",
            "research_field": "Materials Science",
            "research_topics": ["Smart Materials", "Sensors", "IoT"],
            "owner_id": 4
        },
        {
            "name": "Cognitive Robotics Team",
            "description": "인지 로봇 시스템 연구",
            "research_field": "Robotics",
            "research_topics": ["Cognitive Systems", "Human-Robot Interaction"],
            "owner_id": 5
        },
        {
            "name": "ML Systems Lab",
            "description": "기계학습 시스템 최적화 연구",
            "research_field": "AI Healthcare",
            "research_topics": ["Machine Learning", "Systems", "Optimization"],
            "owner_id": 1
        },
        {
            "name": "Medical AI Applications",
            "description": "의료 진단을 위한 AI 응용",
            "research_field": "AI Healthcare",
            "research_topics": ["Medical AI", "Diagnostics", "Healthcare"],
            "owner_id": 1
        },
        {
            "name": "Neurodegenerative Disease Research",
            "description": "신경퇴행성 질환의 메커니즘 및 치료법 연구",
            "research_field": "Brain Mapping",
            "research_topics": ["Alzheimer's", "Parkinson's", "Neural Degeneration"],
            "owner_id": 7
        },
        {
            "name": "Sustainable Energy Systems",
            "description": "지속가능한 에너지 시스템 개발 연구",
            "research_field": "Climate Change",
            "research_topics": ["Renewable Energy", "Smart Grid", "Energy Storage"],
            "owner_id": 8
        },
        {
            "name": "Consumer Psychology Lab",
            "description": "소비자 행동 및 의사결정 연구",
            "research_field": "Behavioral Science",
            "research_topics": ["Consumer Behavior", "Decision Making", "Marketing"],
            "owner_id": 9
        },
        {
            "name": "Quantum Machine Learning",
            "description": "양자 컴퓨팅을 활용한 기계학습 연구",
            "research_field": "Quantum Computing",
            "research_topics": ["Quantum ML", "Quantum Neural Networks"],
            "owner_id": 2
        },
        {
            "name": "Biomedical Data Science",
            "description": "생물의학 데이터 분석 및 모델링",
            "research_field": "Data Science",
            "research_topics": ["Biomedical Data", "Health Analytics", "ML in Medicine"],
            "owner_id": 6
        },
        {
            "name": "Digital Health Innovations",
            "description": "디지털 헬스케어 솔루션 연구",
            "research_field": "AI Healthcare",
            "research_topics": ["Digital Health", "Telemedicine", "Health Tech"],
            "owner_id": 1
        },
        {
            "name": "Evolutionary Genetics",
            "description": "진화 유전학 및 적응 메커니즘 연구",
            "research_field": "Genetics",
            "research_topics": ["Evolution", "Adaptation", "Population Genetics"],
            "owner_id": 3
        },
        {
            "name": "Human-AI Collaboration",
            "description": "인간-AI 협력 시스템 연구",
            "research_field": "Robotics",
            "research_topics": ["Human-AI Interaction", "Collaborative AI", "UX"],
            "owner_id": 5
        },
        {
            "name": "Blockchain Economics",
            "description": "블록체인 기술의 경제적 영향 연구",
            "research_field": "Financial Technology",
            "research_topics": ["Crypto Economics", "DeFi", "Digital Currency"],
            "owner_id": 10
        },
        {
            "name": "Neural Engineering Lab",
            "description": "신경공학 및 뇌-기계 인터페이스 연구",
            "research_field": "Brain Mapping",
            "research_topics": ["Neural Interfaces", "Brain-Computer Interface", "Neurotech"],
            "owner_id": 7
        }
    ]

    try:
        for workspace_data in workspaces:
            workspace = Workspace(
                name=workspace_data["name"],
                description=workspace_data["description"],
                research_field=workspace_data["research_field"],
                research_topics=workspace_data["research_topics"],
                owner_id=workspace_data["owner_id"],
                is_public=True,
                member_count=1
            )
            db.add(workspace)
            db.flush()

            # owner를 멤버로 추가
            owner_member = WorkspaceMember(
                workspace_id=workspace.id,
                user_id=workspace_data["owner_id"],
                role="admin"
            )
            db.add(owner_member)
            db.flush()

            # 같은 연구 분야의 사용자들을 멤버로 추가
            similar_users = [
                user_data for user_data in test_users
                if (user_data["research_field"] == workspace_data["research_field"] or 
                    any(topic in user_data["research_interests"] for topic in workspace_data["research_topics"]))
                and user_data["email"] != f"user{workspace_data['owner_id']}@test.com"
            ]
            
            # 유사한 연구 분야의 사용자 중 최대 3명을 랜덤하게 선택
            selected_users = random.sample(similar_users, min(3, len(similar_users)))
            
            for user_data in selected_users:
                user_id = int(user_data["email"].split("user")[1].split("@")[0])
                member = WorkspaceMember(
                    workspace_id=workspace.id,
                    user_id=user_id,
                    role="member"
                )
                db.add(member)
            
            # 멤버 수 업데이트
            workspace.member_count = 1 + len(selected_users)

        db.commit()

    except Exception as e:
        print(f"Error creating workspaces: {e}")
        db.rollback()
    finally:
        db.close()