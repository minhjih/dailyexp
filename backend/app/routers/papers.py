from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List, Optional
from ..services.ieee_service import IEEEService
from ..models.database import get_db
from ..models import models
from ..schemas import paper_schemas
from ..services.gpt_service import GPTService
from ..utils.auth import get_current_user

router = APIRouter(
    prefix="/papers",
    tags=["papers"]
)

ieee_service = IEEEService()
gpt_service = GPTService()

@router.get("/search")
async def search_papers(
    keywords: str,
    start_record: int = 1,
    max_records: int = 25,
    start_year: Optional[str] = None,
    end_year: Optional[str] = None,
    db: Session = Depends(get_db)
):
    try:
        # IEEE API를 통해 논문 검색
        search_results = await ieee_service.search_papers(
            keywords=keywords,
            start_record=start_record,
            max_records=max_records,
            start_year=start_year,
            end_year=end_year
        )

        # 검색 결과가 없는 경우
        if not search_results.get("articles"):
            return {"message": "No papers found", "papers": []}

        # 검색된 논문들을 파싱
        papers = []
        for article in search_results.get("articles", []):
            parsed_paper = ieee_service.parse_paper_data(article)
            papers.append(parsed_paper)

        return {
            "total_records": search_results.get("total_records", 0),
            "papers": papers
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

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