# 연구 플랫폼 백엔드

## 데이터베이스 구조

### 사용자 (Users)
```sql
CREATE TABLE users (
    id SERIAL PRIMARY KEY, -- 사용자 고유 ID
    email VARCHAR(255) UNIQUE NOT NULL, -- 이메일 (고유값)
    full_name VARCHAR(255) NOT NULL, -- 이름
    hashed_password VARCHAR(255) NOT NULL, -- 암호화된 비밀번호
   created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 계정 생성일
   institution VARCHAR(255), -- 소속 기관
   department VARCHAR(255), -- 소속 학과
   research_field VARCHAR(255), -- 연구 분야
   research_interests TEXT[], -- 연구 관심사 (배열)
   bio TEXT, -- 자기소개
   external_links JSONB, -- 외부 링크 (JSON 형식)
   profile_image_url VARCHAR(255) -- 프로필 이미지 URL
);
```

### 논문 (Papers)
```sql
CREATE TABLE papers (
    id SERIAL PRIMARY KEY,                    -- 논문 고유 ID
    ieee_id VARCHAR(255) UNIQUE NOT NULL,     -- IEEE 논문 ID
    title TEXT NOT NULL,                      -- 논문 제목
    abstract TEXT NOT NULL,                   -- 초록
    authors TEXT[] NOT NULL,                  -- 저자 목록 (배열)
    published_date TIMESTAMP NOT NULL,        -- 출판일
    ai_summary JSONB,                         -- AI 요약 (JSON 형식)
    core_claims TEXT,                         -- 핵심 주장
    methodology TEXT,                         -- 연구 방법론
    key_findings TEXT,                        -- 주요 발견
    visual_elements JSONB,                    -- 시각적 요소 (JSON 형식)
    future_research TEXT,                     -- 향후 연구 방향
    user_id INTEGER REFERENCES users(id),     -- 등록한 사용자 ID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP  -- 등록일
);
```

### 워크스페이스 (Workspaces)
```sql
CREATE TABLE workspaces (
    id SERIAL PRIMARY KEY,                    -- 워크스페이스 고유 ID
    name VARCHAR(255) NOT NULL,               -- 워크스페이스 이름
    description TEXT,                         -- 설명
    research_field VARCHAR(255),              -- 연구 분야
    research_topics TEXT[],                   -- 연구 주제 (배열)
    owner_id INTEGER REFERENCES users(id),    -- 소유자 ID
    is_public BOOLEAN DEFAULT TRUE,           -- 공개 여부
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 생성일
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 수정일
    member_count INTEGER DEFAULT 1            -- 멤버 수
);
```

### 워크스페이스 멤버 (Workspace Members)
```sql
CREATE TABLE workspace_members (
    id SERIAL PRIMARY KEY,                    -- 멤버십 고유 ID
    workspace_id INTEGER REFERENCES workspaces(id),  -- 워크스페이스 ID
    user_id INTEGER REFERENCES users(id),     -- 사용자 ID
    role VARCHAR(50) NOT NULL,                -- 역할 (관리자/멤버 등)
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,   -- 가입일
    UNIQUE(workspace_id, user_id)             -- 워크스페이스당 사용자는 한 번만 가입 가능
);
```

### 워크스페이스 논문 (Workspace Papers)
```sql
CREATE TABLE workspace_papers (
    id SERIAL PRIMARY KEY,                    -- 워크스페이스 논문 고유 ID
    workspace_id INTEGER REFERENCES workspaces(id),  -- 워크스페이스 ID
    paper_id INTEGER REFERENCES papers(id),   -- 논문 ID
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,    -- 추가일
    status VARCHAR(50) DEFAULT 'in_progress', -- 상태 (진행중/완료 등)
    UNIQUE(workspace_id, paper_id)            -- 워크스페이스당 논문은 한 번만 추가 가능
);
```

### 사용자 팔로우 관계 (User Follows)
```sql
CREATE TABLE user_follows (
    id SERIAL PRIMARY KEY,                    -- 팔로우 관계 고유 ID
    follower_id INTEGER REFERENCES users(id), -- 팔로워 ID
    following_id INTEGER REFERENCES users(id), -- 팔로잉 ID
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- 팔로우 시작일
    UNIQUE(follower_id, following_id)         -- 중복 팔로우 방지
);
```

## 관계 구조

- 사용자는 여러 사용자를 팔로우할 수 있음 (다대다 관계, user_follows 테이블을 통해)
- 사용자는 여러 워크스페이스의 멤버가 될 수 있음 (다대다 관계, workspace_members 테이블을 통해)
- 워크스페이스는 여러 논문을 포함할 수 있음 (다대다 관계, workspace_papers 테이블을 통해)
- 논문은 한 명의 사용자에 의해 등록됨 (다대일 관계)
- 워크스페이스는 한 명의 소유자를 가짐 (다대일 관계)

## 주요 기능
- 사용자 인증 및 권한 관리
- 워크스페이스 관리
- 논문 관리
- 소셜 네트워킹 (팔로우/팔로워)
- 연구 협업