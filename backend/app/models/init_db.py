from datetime import datetime
from sqlalchemy.orm import Session
from backend.models import User, Paper, Workspace, WorkspacePaper

def init_db(db: Session):
    # ... existing user creation code ...

    # Create some papers
    papers = [
        Paper(
            ieee_id="paper1",
            title="Quantum Computing Applications in Modern Science",
            abstract="A study on quantum computing applications...",
            authors=["John Doe", "Jane Smith"],
            published_date=datetime.now(),
            user_id=1
        ),
        Paper(
            ieee_id="paper2",
            title="Machine Learning in Healthcare",
            abstract="An analysis of ML applications in healthcare...",
            authors=["Alice Johnson", "Bob Wilson"],
            published_date=datetime.now(),
            user_id=2
        ),
        Paper(
            ieee_id="paper3",
            title="Advanced Neural Networks",
            abstract="Research on neural network architectures...",
            authors=["Charlie Brown", "Diana Lee"],
            published_date=datetime.now(),
            user_id=3
        ),
    ]
    
    for paper in papers:
        db.add(paper)
    db.commit()

    # Create workspaces with papers
    workspaces = [
        Workspace(
            name="Quantum Research Group",
            description="Research group focused on quantum computing",
            research_field="Quantum Computing",
            research_topics=["Quantum Algorithms", "Quantum Hardware"],
            owner_id=1,
            is_public=True,
            member_count=2
        ),
        Workspace(
            name="Healthcare AI Lab",
            description="AI applications in healthcare",
            research_field="Healthcare",
            research_topics=["Medical Imaging", "Disease Prediction"],
            owner_id=2,
            is_public=True,
            member_count=3
        ),
    ]
    
    for workspace in workspaces:
        db.add(workspace)
    db.commit()

    # Add papers to workspaces
    workspace_papers = [
        WorkspacePaper(
            workspace_id=1,  # Quantum Research Group
            paper_id=1,      # Quantum Computing paper
            status="진행중",
            added_at=datetime.now()
        ),
        WorkspacePaper(
            workspace_id=2,  # Healthcare AI Lab
            paper_id=2,      # Healthcare ML paper
            status="완료",
            added_at=datetime.now()
        ),
        WorkspacePaper(
            workspace_id=2,  # Healthcare AI Lab
            paper_id=3,      # Neural Networks paper
            status="검토중",
            added_at=datetime.now()
        ),
    ]
    
    for wp in workspace_papers:
        db.add(wp)
    db.commit() 