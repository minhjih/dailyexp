# Research Platform Backend

## 데이터베이스 구조

### 엔티티 관계도 
User
├── 소유 Workspaces (1:N)
├── WorkspaceMembers (1:N)
└── Papers (1:N)
Workspace
├── Owner (N:1 → User)
├── WorkspaceMembers (1:N)
└── WorkspacePapers (1:N)
Paper
├── Owner (N:1 → User)
└── WorkspacePapers (1:N)

### 주요 모델 설명

1. **User (사용자)**
   - 기본 정보: id, email, full_name
   - 프로필 정보: institution, department, research_field
   - 연구 관련: research_interests, bio
   - 외부 링크: external_links, profile_image_url

2. **Workspace (워크스페이스)**
   - 기본 정보: id, name, description
   - 연구 분야: research_field, research_topics
   - 관리 정보: owner_id, is_public, member_count
   - 시간 정보: created_at, updated_at

3. **WorkspaceMember (워크스페이스 멤버)**
   - 연결 정보: workspace_id, user_id
   - 멤버 정보: role, joined_at

4. **Paper (논문)**
   - 기본 정보: id, ieee_id, title, abstract
   - 저자 정보: authors, published_date
   - AI 분석: ai_summary, core_claims
   - 연구 내용: methodology, key_findings
   - 부가 정보: visual_elements, future_research

5. **WorkspacePaper (워크스페이스 논문)**
   - 연결 정보: workspace_id, paper_id
   - 상태 정보: status, added_at

## 초기 설정

1. 환경 변수 설정 (.env 파일)
```env
DATABASE_URL=postgresql://postgres:password@db:5432/researchdb
SECRET_KEY=your_secret_key
OPENAI_API_KEY=your_openai_api_key
IEEE_API_KEY=your_ieee_api_key
```

2. Docker 실행
```bash
# 컨테이너 시작
docker-compose up --build

# 컨테이너 중지 및 삭제
docker-compose down

# 볼륨 삭제 (데이터베이스 초기화)
docker volume rm backend_postgres_data
```

## API 엔드포인트

### 인증
- POST `/auth/signup`: 회원가입
- POST `/auth/login`: 로그인
- GET `/auth/me`: 현재 사용자 정보

### 워크스페이스
- GET `/workspaces/recommended`: 추천 워크스페이스 목록
- GET `/workspaces/my`: 내 워크스페이스 목록
- POST `/workspaces/{workspace_id}/join`: 워크스페이스 가입
- GET `/workspaces/search`: 워크스페이스 검색

### 사용자
- GET `/profile/me`: 내 프로필
- GET `/profile/{user_id}`: 사용자 프로필
- GET `/profile/me/stats`: 프로필 통계
- POST `/profile/{user_id}/follow`: 사용자 팔로우

## 개발 가이드

1. 새로운 모델 추가 시:
   - models/ 디렉토리에 모델 정의
   - schemas/ 디렉토리에 Pydantic 스키마 정의
   - routers/ 디렉토리에 API 엔드포인트 정의

2. 데이터베이스 초기화:
   - models/init_db.py 파일에 초기 데이터 정의
   - 컨테이너 재시작 시 자동으로 적용

3. API 테스트:
   - Swagger UI: http://localhost:8000/docs
   - ReDoc: http://localhost:8000/redoc