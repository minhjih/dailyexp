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
- 인증: Bearer 토큰 필요
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

## 인증 API

### 회원가입
POST /auth/signup
- 설명: 새로운 사용자를 등록합니다
- 요청 본문:
  {
    "email": "user@example.com",
    "full_name": "User Name",
    "password": "strongpassword"
  }
- 응답 예시:
  {
    "email": "user@example.com",
    "full_name": "User Name",
    "id": 1,
    "created_at": "2023-01-01T00:00:00"
  }

### 로그인
POST /auth/login
- 설명: 사용자 로그인 및 액세스 토큰 발급
- 요청 본문 (form-data):
  - username: 이메일 주소
  - password: 비밀번호
- 응답 예시:
  {
    "access_token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
    "token_type": "bearer"
  }

### 내 정보 조회
GET /auth/me
- 설명: 현재 로그인한 사용자의 정보를 조회
- 인증: Bearer 토큰 필요
- 응답 예시:
  {
    "email": "user@example.com",
    "full_name": "User Name",
    "id": 1,
    "created_at": "2023-01-01T00:00:00"
  }

## 스크랩 API

### 스크랩 생성
POST /scraps
- 설명: 새로운 스크랩을 생성합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "content": "스크랩할 텍스트 내용",
    "image_url": "이미지 URL",
    "scrap_type": "text" 또는 "image",
    "note": "사용자 메모",
    "page_number": 1,
    "paper_id": 123
  }

### 스크랩 목록 조회
GET /scraps
- 설명: 사용자의 스크랩 목록을 조회합니다
- 인증: Bearer 토큰 필요
- 쿼리 파라미터:
  - paper_id: int (선택) - 특정 논문의 스크랩만 조회
  - skip: int (선택, 기본값=0) - 건너뛸 항목 수
  - limit: int (선택, 기본값=100) - 반환할 최대 항목 수

### 스크랩 수정
PUT /scraps/{scrap_id}
- 설명: 기존 스크랩을 수정합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "content": "수정된 내용",
    "note": "수정된 메모"
  }

### 스크랩 삭제
DELETE /scraps/{scrap_id}
- 설명: 스크랩을 삭제합니다
- 인증: Bearer 토큰 필요

### 태그 생성
POST /scraps/tags
- 설명: 새로운 태그를 생성합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "name": "태그명"
  }

### 태그 목록 조회
GET /scraps/tags
- 설명: 사용자의 모든 태그를 조회합니다
- 인증: Bearer 토큰 필요

### 스크랩 공유
POST /scraps/{scrap_id}/share
- 설명: 스크랩을 다른 사용자와 공유합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "shared_with_user_id": 123
  }

### 공유받은 스크랩 조회
GET /scraps/shared
- 설명: 다른 사용자가 공유한 스크랩을 조회합니다
- 인증: Bearer 토큰 필요

### 스크랩 검색
GET /scraps/search
- 설명: 스크랩을 검색합니다
- 인증: Bearer 토큰 필요
- 쿼리 파라미터:
  - query: str - 검색어
  - tag_ids: List[int] - 태그 ID 목록 (선택)

## 그룹 API

### 그룹 생성
POST /groups
- 설명: 새로운 그룹을 생성합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "name": "그룹명",
    "description": "그룹 설명"
  }

### 내 그룹 목록 조회
GET /groups
- 설명: 사용자가 속한 모든 그룹을 조회합니다
- 인증: Bearer 토큰 필요

### 그룹 멤버 추가
POST /groups/{group_id}/members
- 설명: 그룹에 새 멤버를 추가합니다
- 인증: Bearer 토큰 필요 (그룹 관리자만 가능)
- 요청 본문:
  {
    "user_id": 123,
    "role": "member"
  }

### 논문 그룹 공유
POST /groups/{group_id}/papers
- 설명: 논문을 그룹과 공유합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "paper_id": 123,
    "note": "공유 메모"
  }

### 스크랩 그룹 공유
POST /groups/{group_id}/scraps
- 설명: 스크랩을 그룹과 공유합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "scrap_id": 123,
    "note": "공유 메모"
  }

### 그룹 공유 논문 조회
GET /groups/{group_id}/papers
- 설명: 그룹에 공유된 논문들을 조회합니다
- 인증: Bearer 토큰 필요

### 그룹 공유 스크랩 조회
GET /groups/{group_id}/scraps
- 설명: 그룹에 공유된 스크랩들을 조회합니다
- 인증: Bearer 토큰 필요

## 댓글 API

### 댓글 작성
POST /comments
- 설명: 새로운 댓글을 작성합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "content": "댓글 내용",
    "target_type": "paper/scrap/group_paper/group_scrap",
    "target_id": 123,
    "parent_id": null  // 대댓글인 경우 부모 댓글 ID
  }

### 댓글 목록 조회
GET /comments/target/{target_type}/{target_id}
- 설명: 특정 대상의 댓글들을 조회합니다
- 인증: Bearer 토큰 필요

### 댓글 수정
PUT /comments/{comment_id}
- 설명: 댓글을 수정합니다
- 인증: Bearer 토큰 필요
- 요청 본문:
  {
    "content": "수정된 댓글 내용"
  }

### 댓글 삭제
DELETE /comments/{comment_id}
- 설명: 댓글을 삭제합니다
- 인증: Bearer 토큰 필요 