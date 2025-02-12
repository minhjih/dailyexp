from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..services.ieee_service import IEEEService
from ..models.database import get_db
from ..models import models
from ..schemas import paper_schemas
from ..services.gpt_service import GPTService
from ..utils.auth import get_current_user
from ..services.arxiv_service import ArxivService
from datetime import datetime, timedelta
from sqlalchemy import func

router = APIRouter(
    prefix="/papers",
    tags=["papers"]
)

ieee_service = IEEEService()
gpt_service = GPTService()
arxiv_service = ArxivService()

@router.get("/search")
async def search_papers(
    query: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    papers = await arxiv_service.search_papers(query)
    return papers

@router.get("/analyze/{paper_id}")
async def analyze_paper(
    paper_id: str,
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    try:
        # 1. IEEE API에서 논문 전체 데이터 가져오기
        paper_data = await ieee_service.get_paper_details(paper_id)
        
        # 2. GPT로 논문 분석
        analysis = await gpt_service.analyze_paper(paper_data)
        
        # 3. 분석 결과를 DB에 저장
        paper = db.query(models.Paper).filter(models.Paper.ieee_id == paper_id).first()
        if paper:
            paper.ai_summary = analysis
            db.commit()
        
        return analysis

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/trending")
async def get_trending_papers(
    db: Session = Depends(get_db),
    current_user: models.User = Depends(get_current_user)
):
    # 최근 일주일 동안의 포스트 수를 기준으로 트렌딩 논문 선정
    trending_papers = (
        db.query(models.Paper)
        .join(models.Post)
        .filter(
            models.Post.created_at >= datetime.utcnow() - timedelta(days=7)
        )
        .group_by(models.Paper.id)
        .order_by(func.count(models.Post.id).desc())
        .limit(3)
        .all()
    )
    
    # 각 논문의 포스트 수도 함께 반환
    return [{
        **paper.to_dict(),
        'post_count': db.query(models.Post)
            .filter(models.Post.paper_id == paper.id)
            .count()
    } for paper in trending_papers] 