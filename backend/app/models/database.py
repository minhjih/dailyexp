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

DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://postgres:password@db/researchdb")

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
        GroupSharedPaper, GroupSharedScrap, Post, PostLike, 
        PostSave, PostComment
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
    
    # 테스트 논문 데이터 생성
    test_papers = [
        {
            "title": "Attention Is All You Need",
            "authors": ["Ashish Vaswani", "Noam Shazeer", "Niki Parmar", "Jakob Uszkoreit", "Llion Jones", "Aidan N. Gomez", "Łukasz Kaiser", "Illia Polosukhin"],
            "abstract": "The dominant sequence transduction models are based on complex recurrent or convolutional neural networks that include an encoder and a decoder. The best performing models also connect the encoder and decoder through an attention mechanism. We propose a new simple network architecture, the Transformer, based solely on attention mechanisms, dispensing with recurrence and convolutions entirely.",
            "published_date": "2017-06-12",
            "arxiv_id": "1706.03762",
            "url": "https://arxiv.org/abs/1706.03762",
            "categories": ["cs.CL", "cs.LG", "cs.AI"],
            "user_id": 1
        },
        {
            "title": "BERT: Pre-training of Deep Bidirectional Transformers for Language Understanding",
            "authors": ["Jacob Devlin", "Ming-Wei Chang", "Kenton Lee", "Kristina Toutanova"],
            "abstract": "We introduce a new language representation model called BERT, which stands for Bidirectional Encoder Representations from Transformers. Unlike recent language representation models, BERT is designed to pre-train deep bidirectional representations from unlabeled text by jointly conditioning on both left and right context in all layers.",
            "published_date": "2018-10-11",
            "arxiv_id": "1810.04805",
            "url": "https://arxiv.org/abs/1810.04805",
            "categories": ["cs.CL"],
            "user_id": 1
        },
        {
            "title": "Quantum Supremacy Using a Programmable Superconducting Processor",
            "authors": ["John Martinis", "Sergio Boixo"],
            "abstract": "The promise of quantum computers is that certain computational tasks might be executed exponentially faster on a quantum processor than on a classical processor. We report the use of a quantum processor to perform a computational task that is prohibitively hard for classical computers.",
            "published_date": "2019-10-23",
            "arxiv_id": "1910.11333",
            "url": "https://arxiv.org/abs/1910.11333",
            "categories": ["quant-ph", "physics.comp-ph"],
            "user_id": 2
        },
        {
            "title": "A Comprehensive Survey of Genetic Variations in Human Populations",
            "authors": ["Emily Wang", "David Chen", "Sarah Johnson"],
            "abstract": "This study presents a comprehensive analysis of genetic variations across diverse human populations, identifying key patterns of inheritance and evolutionary adaptations that contribute to our understanding of human genetic diversity.",
            "published_date": "2020-03-15",
            "arxiv_id": "2003.12345",
            "url": "https://arxiv.org/abs/2003.12345",
            "categories": ["q-bio.GN", "q-bio.PE"],
            "user_id": 3
        },
        {
            "title": "Novel Nanomaterials for Energy Storage Applications",
            "authors": ["Michael Brown", "Jennifer Lee", "Robert Wilson"],
            "abstract": "We present a review of recent advances in nanomaterial development for energy storage applications, with a focus on battery technologies and supercapacitors that demonstrate significant improvements in capacity, charging rates, and cycle life.",
            "published_date": "2021-05-20",
            "arxiv_id": "2105.54321",
            "url": "https://arxiv.org/abs/2105.54321",
            "categories": ["cond-mat.mtrl-sci", "physics.app-ph"],
            "user_id": 4
        },
        {
            "title": "Autonomous Robot Navigation Using Reinforcement Learning",
            "authors": ["Lisa Kim", "James Park", "Thomas Anderson"],
            "abstract": "This paper introduces a novel approach to autonomous robot navigation in complex environments using deep reinforcement learning techniques that enable robots to learn optimal navigation strategies through interaction with their environment.",
            "published_date": "2022-01-10",
            "arxiv_id": "2201.67890",
            "url": "https://arxiv.org/abs/2201.67890",
            "categories": ["cs.RO", "cs.AI", "cs.LG"],
            "user_id": 5
        },
        {
            "title": "Statistical Methods for Large-Scale Data Analysis",
            "authors": ["David Lee", "Maria Garcia", "John Smith"],
            "abstract": "We propose new statistical methods for analyzing large-scale datasets, addressing challenges related to high dimensionality, sparse data structures, and computational efficiency in modern data science applications.",
            "published_date": "2021-11-05",
            "arxiv_id": "2111.13579",
            "url": "https://arxiv.org/abs/2111.13579",
            "categories": ["stat.ML", "cs.LG", "math.ST"],
            "user_id": 6
        },
        {
            "title": "Neural Correlates of Consciousness: A Review",
            "authors": ["Anna Martinez", "Paul Johnson", "Susan Brown"],
            "abstract": "This review examines the current understanding of neural correlates of consciousness, synthesizing evidence from neuroimaging studies, electrophysiological recordings, and clinical observations to identify brain regions and mechanisms essential for conscious experience.",
            "published_date": "2020-08-22",
            "arxiv_id": "2008.24680",
            "url": "https://arxiv.org/abs/2008.24680",
            "categories": ["q-bio.NC", "cs.AI"],
            "user_id": 7
        },
        {
            "title": "Climate Change Impact on Biodiversity: A Global Assessment",
            "authors": ["James Wilson", "Emma Davis", "Michael Chen"],
            "abstract": "This global assessment quantifies the impact of climate change on biodiversity across terrestrial and marine ecosystems, identifying vulnerable species, critical habitats, and potential conservation strategies to mitigate biodiversity loss.",
            "published_date": "2022-03-15",
            "arxiv_id": "2203.97531",
            "url": "https://arxiv.org/abs/2203.97531",
            "categories": ["q-bio.PE", "physics.ao-ph"],
            "user_id": 8
        },
        {
            "title": "The Psychology of Decision-Making Under Uncertainty",
            "authors": ["Sophie Taylor", "Richard Brown", "Elizabeth White"],
            "abstract": "This study investigates how individuals make decisions under conditions of uncertainty, examining cognitive biases, emotional influences, and contextual factors that shape human decision-making processes in complex environments.",
            "published_date": "2021-09-30",
            "arxiv_id": "2109.86420",
            "url": "https://arxiv.org/abs/2109.86420",
            "categories": ["cs.CY", "cs.AI", "q-bio.NC"],
            "user_id": 9
        },
        {
            "title": "Blockchain Technology in Financial Markets: Opportunities and Challenges",
            "authors": ["Robert Garcia", "Linda Martinez", "William Johnson"],
            "abstract": "This paper analyzes the potential applications of blockchain technology in financial markets, discussing opportunities for increased efficiency, transparency, and security, while addressing regulatory challenges and implementation barriers.",
            "published_date": "2022-02-10",
            "arxiv_id": "2202.12345",
            "url": "https://arxiv.org/abs/2202.12345",
            "categories": ["cs.CR", "q-fin.GN"],
            "user_id": 10
        }
    ]

    try:
        for paper_data in test_papers:
            paper = Paper(
                title=paper_data["title"],
                authors=paper_data["authors"],
                abstract=paper_data["abstract"],
                published_date=paper_data["published_date"],
                arxiv_id=paper_data["arxiv_id"],
                url=paper_data["url"],
                categories=paper_data["categories"],
                user_id=paper_data["user_id"],
                created_at=datetime.datetime.utcnow()
            )
            db.add(paper)
        
        db.commit()
    except Exception as e:
        print(f"Error creating test papers: {e}")
        db.rollback()

    # 테스트 포스트 데이터 생성
    test_posts = [
        # 사용자 1의 포스트
        {
            "title": "트랜스포머 모델의 혁신적 접근",
            "content": "트랜스포머 모델은 자연어 처리 분야에 혁명을 가져왔습니다. 기존의 RNN, LSTM 모델과 달리 병렬 처리가 가능하여 학습 속도가 빠르고 성능도 뛰어납니다.",
            "paper_title": "Attention Is All You Need",
            "key_insights": ["어텐션 메커니즘만으로 시퀀스 모델링 가능", "병렬 처리로 학습 속도 향상", "장거리 의존성 포착에 효과적"],
            "author_id": 1,
            "paper_id": 1
        },
        # 사용자 2의 포스트
        {
            "title": "양자 우월성 달성의 의미",
            "content": "구글의 양자 컴퓨터가 특정 계산 작업에서 양자 우월성을 달성했다는 것은 양자 컴퓨팅 분야의 중요한 이정표입니다. 이 포스트에서는 그 의미와 향후 전망에 대해 논의합니다.",
            "paper_title": "Quantum Supremacy Using a Programmable Superconducting Processor",
            "key_insights": ["양자 우월성의 실험적 증명", "초전도체 기반 양자 프로세서의 가능성", "양자 컴퓨팅의 미래 전망"],
            "author_id": 2,
            "paper_id": 3
        },
        # 사용자 3의 포스트
        {
            "title": "인간 유전적 다양성의 패턴",
            "content": "인간 집단 간의 유전적 변이에 대한 포괄적인 연구 결과를 공유합니다. 이 연구는 인류의 진화 역사와 적응 메커니즘에 대한 중요한 통찰을 제공합니다.",
            "paper_title": "A Comprehensive Survey of Genetic Variations in Human Populations",
            "key_insights": ["인구 집단별 유전적 변이 패턴", "자연 선택의 증거", "질병 관련 유전자 변이"],
            "author_id": 3,
            "paper_id": 4
        },
        # 사용자 4의 포스트
        {
            "title": "에너지 저장을 위한 나노소재 개발",
            "content": "배터리 기술의 혁신을 위한 나노소재 연구 동향을 소개합니다. 용량, 충전 속도, 수명 등 여러 측면에서 획기적인 개선을 보이는 최신 연구 결과들을 정리했습니다.",
            "paper_title": "Novel Nanomaterials for Energy Storage Applications",
            "key_insights": ["나노구조의 에너지 저장 효율성", "배터리 수명 연장 기술", "친환경 에너지 저장 솔루션"],
            "author_id": 4,
            "paper_id": 5
        },
        # 사용자 5의 포스트
        {
            "title": "강화학습을 통한 로봇 자율 주행",
            "content": "복잡한 환경에서 로봇이 강화학습을 통해 자율적으로 주행하는 방법에 대한 연구 결과입니다. 실제 환경과의 상호작용을 통해 최적의 주행 전략을 학습하는 과정이 흥미롭습니다.",
            "paper_title": "Autonomous Robot Navigation Using Reinforcement Learning",
            "key_insights": ["환경 인식 및 적응형 주행", "실시간 장애물 회피", "보상 함수 설계의 중요성"],
            "author_id": 5,
            "paper_id": 6
        },
        # 사용자 6의 포스트
        {
            "title": "대규모 데이터 분석을 위한 통계적 방법론",
            "content": "빅데이터 시대에 필요한 새로운 통계적 방법론에 대한 연구입니다. 고차원 데이터, 희소 데이터 구조 등 현대 데이터 과학의 도전 과제를 해결하기 위한 접근법을 제시합니다.",
            "paper_title": "Statistical Methods for Large-Scale Data Analysis",
            "key_insights": ["차원 축소 기법", "희소 데이터 처리 방법", "계산 효율성 향상 알고리즘"],
            "author_id": 6,
            "paper_id": 7
        },
        # 사용자 7의 포스트
        {
            "title": "의식의 신경학적 상관관계",
            "content": "의식의 신경학적 기반에 대한 최신 연구 동향을 정리했습니다. 뇌 영상 연구, 전기생리학적 기록, 임상 관찰 등 다양한 증거를 종합하여 의식 경험에 필수적인 뇌 영역과 메커니즘을 식별합니다.",
            "paper_title": "Neural Correlates of Consciousness: A Review",
            "key_insights": ["의식의 신경학적 기반", "뇌 영역별 역할", "의식 상태 변화의 메커니즘"],
            "author_id": 7,
            "paper_id": 8
        },
        # 사용자 8의 포스트
        {
            "title": "기후 변화가 생물다양성에 미치는 영향",
            "content": "전 지구적 기후 변화가 육상 및 해양 생태계의 생물다양성에 미치는 영향을 정량적으로 평가한 연구입니다. 취약한 종, 중요 서식지, 생물다양성 손실을 완화하기 위한 보전 전략을 제시합니다.",
            "paper_title": "Climate Change Impact on Biodiversity: A Global Assessment",
            "key_insights": ["기후 변화에 취약한 생태계", "종 멸종 위험 평가", "생물다양성 보전 전략"],
            "author_id": 8,
            "paper_id": 9
        },
        # 사용자 9의 포스트
        {
            "title": "불확실성 하에서의 의사결정 심리학",
            "content": "불확실한 상황에서 인간이 어떻게 의사결정을 내리는지에 대한 연구입니다. 인지적 편향, 감정적 영향, 맥락적 요인 등이 복잡한 환경에서 인간의 의사결정 과정을 어떻게 형성하는지 조사했습니다.",
            "paper_title": "The Psychology of Decision-Making Under Uncertainty",
            "key_insights": ["인지적 편향의 영향", "감정과 의사결정의 관계", "불확실성 하에서의 휴리스틱"],
            "author_id": 9,
            "paper_id": 10
        },
        # 사용자 10의 포스트
        {
            "title": "금융 시장에서의 블록체인 기술",
            "content": "금융 시장에서 블록체인 기술의 잠재적 응용에 대한 분석입니다. 효율성, 투명성, 보안성 향상의 기회와 함께 규제적 도전과 구현 장벽에 대해 논의합니다.",
            "paper_title": "Blockchain Technology in Financial Markets: Opportunities and Challenges",
            "key_insights": ["금융 거래의 투명성 향상", "중개자 없는 거래 시스템", "규제 및 보안 과제"],
            "author_id": 10,
            "paper_id": 11
        },
        # 추가 포스트 - 사용자 1
        {
            "title": "AI 연구의 최신 동향",
            "content": "인공지능 연구 분야의 최신 동향과 발전 방향에 대한 개인적인 견해를 공유합니다. 특히 자연어 처리와 컴퓨터 비전 분야의 통합적 접근법이 주목받고 있습니다.",
            "key_insights": ["멀티모달 AI 모델의 부상", "자기지도학습의 발전", "AI 윤리의 중요성"],
            "author_id": 1,
            "paper_id": None
        }
    ]

    try:
        for post_data in test_posts:
            post = Post(
                title=post_data["title"],
                content=post_data["content"],
                paper_title=post_data.get("paper_title"),
                key_insights=post_data.get("key_insights"),
                author_id=post_data["author_id"],
                paper_id=post_data.get("paper_id"),
                created_at=datetime.datetime.utcnow() - datetime.timedelta(days=random.randint(0, 30), hours=random.randint(0, 23), minutes=random.randint(0, 59))
            )
            db.add(post)
        
        db.commit()
    except Exception as e:
        print(f"Error creating test posts: {e}")
        db.rollback()
    finally:
        db.close()