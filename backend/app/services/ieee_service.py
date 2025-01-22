import requests
from typing import List, Optional, Dict
import os
from dotenv import load_dotenv
from datetime import datetime

load_dotenv()

class IEEEService:
    def __init__(self):
        self.api_key = os.getenv("IEEE_API_KEY")
        self.base_url = "http://ieeexploreapi.ieee.org/api/v1/search/articles"

    async def search_papers(
        self,
        keywords: str,
        start_record: int = 1,
        max_records: int = 25,
        start_year: Optional[str] = None,
        end_year: Optional[str] = None,
        sort_order: str = "desc"
    ) -> Dict:
        """
        IEEE API를 통해 논문을 검색합니다.
        """
        params = {
            "apikey": self.api_key,
            "format": "json",
            "max_records": max_records,
            "start_record": start_record,
            "sort_order": sort_order,
            "sort_field": "publication_year",
            "abstract": "true"
        }

        # 검색어 설정
        params["querytext"] = keywords

        # 연도 필터 추가
        if start_year:
            params["start_year"] = start_year
        if end_year:
            params["end_year"] = end_year

        try:
            response = requests.get(self.base_url, params=params)
            response.raise_for_status()
            return response.json()
        except requests.RequestException as e:
            raise Exception(f"IEEE API 요청 실패: {str(e)}")

    def parse_paper_data(self, paper_data: Dict) -> Dict:
        """
        IEEE API로부터 받은 논문 데이터를 우리 시스템에 맞게 파싱합니다.
        """
        return {
            "ieee_id": paper_data.get("article_number"),
            "title": paper_data.get("title"),
            "abstract": paper_data.get("abstract", ""),
            "authors": [
                {"name": author.get("full_name"), "affiliation": author.get("affiliation", [])}
                for author in paper_data.get("authors", [])
            ],
            "published_date": datetime.strptime(
                paper_data.get("publication_date", ""), 
                "%Y-%m-%d"
            ) if paper_data.get("publication_date") else None,
            "doi": paper_data.get("doi", ""),
            "publisher": paper_data.get("publisher", ""),
            "publication_title": paper_data.get("publication_title", "")
        } 