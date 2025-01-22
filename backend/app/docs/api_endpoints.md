# DailyExp API Endpoints

## 논문 검색 API
GET /papers/search
- 설명: IEEE API를 통해 논문을 검색합니다
- 파라미터:
  - keywords: str (필수) - 검색할 키워드
  - start_record: int (선택, 기본값=1) - 검색 시작 위치
  - max_records: int (선택, 기본값=25) - 반환할 최대 논문 수
  - start_year: str (선택) - 검색 시작 연도
  - end_year: str (선택) - 검색 종료 연도
- 응답 예시:
  {
    "total_records": 100,
    "papers": [
      {
        "ieee_id": "12345",
        "title": "Paper Title",
        "abstract": "Paper Abstract",
        "authors": [...],
        "published_date": "2023-01-01"
      }
    ]
  }

## 논문 분석 API
GET /papers/analyze/{paper_id}
- 설명: GPT-4를 사용하여 특정 논문을 상세 분석합니다
- 파라미터:
  - paper_id: str (필수) - IEEE 논문 ID
- 응답 예시:
  {
    "core_claims": "논문의 핵심 주장...",
    "section_summaries": {
      "introduction": "...",
      "methodology": "..."
    },
    "methodology": "연구 방법론 설명...",
    "key_findings": [
      "주요 발견 1",
      "주요 발견 2"
    ],
    "visual_elements": [
      {
        "type": "figure",
        "id": "Fig.1",
        "description": "..."
      }
    ],
    "future_research": "향후 연구 방향..."
  } 