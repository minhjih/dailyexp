- [KOR](#겉핥기)
- [ENG](#Glimpse)

# Glimpse
<div style="display: flex; gap: 20px;">
    <img src="screenshots/Mobile1.png" width="100%" height="50%"/>
</div>

Glimpse is an innovative research tracking and knowledge sharing platform designed for graduate students. It offers a comprehensive solution for receiving recommendations on the latest papers in your field of interest, capturing key insights, sharing them with your research group, and publicly posting your paper reviews to spread knowledge in a short-form.

## Key Features

- **Personalized Paper Recommendations**: Get daily recommendations for papers from top journals in your area of interest.
- **Intuitive Summaries**: Receive concise summaries and key intuitions from recommended papers.
- **Scrap and Share**: Easily scrap important sections and instantly share them with your research group.
- **Public Review Posting**: Post your paper reviews publicly to disseminate knowledge.
- **Follow System**: Follow other researchers to gain insights from their work and reviews.
- **Integrated Workspace**: A unified workspace for individual and group research activities.

## Tech Stack

### Frontend
- **Flutter**: Cross-platform mobile application development

<img alt="Flutter" src ="https://img.shields.io/badge/Flutter-02569B.svg?&style=for-the-badge&logo=Flutter&logoColor=white"/>

### Backend
- **Python**: Server-side logic implementation
- **AWS**: Cloud infrastructure and service hosting
- **OpenAI**: AI-powered paper analysis and summarization
- **FastAPI**: High-performance API development

<img alt="Python" src ="https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54"/> <img alt="AWS" src ="https://img.shields.io/badge/AWS-232F3E.svg?style=for-the-badge&logo=amazonwebservices&logoColor=white"/> <img alt="Openai" src ="https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=OpenAI&logoColor=white"/> <img alt="FastAPI" src ="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=FastAPI&logoColor=white"/> 


## Usage

1. Launch the app and create an account.
2. Set your research interests.
3. Browse recommended papers and read their summaries.
4. Scrap important sections and share them with your research group.
5. Write and publicly post your personal reviews of papers.
6. Follow other researchers and gain insights from their work.

## Current Project Progress (Glimpse)

### Completed Features
✅ Login Page Implementation
- User authentication logic finalized
- Basic UI/UX design applied
- Secure login mechanism integrated

✅ Main Page Framework
- Preliminary layout and navigation structure established
- Initial component drafts created
- Basic routing between screens

✅ Main page sync to frontend design
- login & signup screens
- feed screen, Workspaces_main, Workspace_detail_screen1, paper, social, profile screens

✅ Paper Recommendation Section
- Integrate Arxiv API for intelligent recommendations
- Develop user interest-based recommendation algorithm
- Design personalized research feed

✅ Posting Functionality
- Implement post creation, retrieval, editing, and deletion API
- Implement like, save, and comment functionality
- Implement following-based feed retrieval functionality

✅ Profile Management
- User profile creation and editing
- Profile image upload and management
- Research interests and bio information management

✅ UI/UX Enhancements
- Improved navigation bar with hide/show animation
- Optimized layout for different screen sizes
- Enhanced profile image handling with cache busting

### Recent Updates
✅ Profile Image Management
- Added profile image upload functionality
- Implemented image cache invalidation for immediate updates
- Configured Docker to clean media directory on restart
- Fixed image URL handling between frontend and backend

✅ UI Responsiveness
- Fixed app bar and navigation bar overlap issues
- Improved content area sizing and positioning
- Enhanced screen transitions and animations

### Ongoing Development
🔨 Details of frontend
- posting details

🔨 Review Posting System
- Develop paper review writing/editing page
- Implement public/private review settings
- Add tagging and categorization options

### Next Development Stages

1. Scraping and Sharing Functionality
- Implement paper scraping mechanism
- Design group sharing interface
- Create annotation and highlight features

### Technical Considerations
- State Management (Provider/Riverpod)
- Network communication optimization
- Enhanced security protocols
- Performance monitoring
- Error handling strategies

### Potential Challenges
- API integration complexity
- Scalable recommendation engine
- Cross-platform UI consistency
- Data privacy and user permissions
- Chrome extension


## Contact

Project Maintainer - [@minji](https://www.linkedin.com/in/minhjih?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app) - jhchoi0226@snu.ac.kr

Frontend Co-worker - [@jadestarmin](https://www.linkedin.com/in/minkyu-park-591b912b5?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app) - jadestar@postech.ac.kr 

Project Link: [https://github.com/minhjih/dailyexp](https://github.com/minhjih/dailyexp)

# 겉핥기
<div style="display: flex; gap: 20px;">
    <img src="screenshots/Mobile1.png" width="100%" height="50%"/>
</div>
겉핥기(가제)는 대학원생을 위해 설계된 혁신적인 연구 추적 및 지식 공유 플랫폼입니다. 관심 분야의 최신 논문에 대한 추천을 받고, 핵심 통찰력을 포착하며, 연구 그룹과 공유하고, 논문 리뷰를 공개적으로 게시하여 빠른 연구 변화에 숏폼 형태로 지식을 전파, 수용 할 수 있는 종합적인 솔루션을 제공합니다.

## 주요 기능

- **개인화된 논문 추천**: 관심 분야의 주요 저널에서 매일 논문 추천을 받습니다.
- **직관적인 요약**: 추천된 논문의 간결한 요약과 핵심 직관을 제공받습니다.
- **스크랩 및 공유**: 중요한 섹션을 쉽게 스크랩하고 연구 그룹과 즉시 공유할 수 있습니다.
- **공개 리뷰 게시**: 논문 리뷰를 공개적으로 게시하여 지식을 전파합니다.
- **팔로우 시스템**: 다른 연구자들을 팔로우하여 그들의 작업과 리뷰에서 통찰력을 얻습니다.
- **통합 워크스페이스**: 개인 및 그룹 연구 활동을 위한 통합 워크스페이스를 제공합니다.

## 기술 스택

### 프론트엔드
- **Flutter**: 크로스 플랫폼 모바일 애플리케이션 개발

<img alt="Flutter" src ="https://img.shields.io/badge/Flutter-02569B.svg?&style=for-the-badge&logo=Flutter&logoColor=white"/>

### 백엔드
- **Python**: 서버 사이드 로직 구현
- **AWS**: 클라우드 인프라 및 서비스 호스팅
- **OpenAI**: AI 기반 논문 분석 및 요약
- **FastAPI**: 고성능 API 개발

<img alt="Python" src ="https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54"/> <img alt="AWS" src ="https://img.shields.io/badge/AWS-232F3E.svg?style=for-the-badge&logo=amazonwebservices&logoColor=white"/> <img alt="Openai" src ="https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=OpenAI&logoColor=white"/> <img alt="FastAPI" src ="https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=FastAPI&logoColor=white"/> 

## 사용 방법

1. 앱을 실행하고 계정을 생성합니다.
2. 연구 관심사를 설정합니다.
3. 추천된 논문을 탐색하고 요약을 읽습니다.
4. 중요한 섹션을 스크랩하고 연구 그룹과 공유합니다.
5. 개인적인 논문 리뷰를 작성하고 공개적으로 게시합니다.
6. 다른 연구자들을 팔로우하고 그들의 작업에서 통찰력을 얻습니다.

## 현재 프로젝트 진행 상황 (Glimpse)

### 완료된 기능
✅ 로그인 페이지 구현
- 사용자 인증 로직 완성
- 기본 UI/UX 디자인 적용
- 보안 로그인 메커니즘 통합

✅ 메인 페이지 프레임워크
- 예비 레이아웃 및 내비게이션 구조 확립
- 초기 컴포넌트 초안 생성
- 화면 간 기본 라우팅

✅ 프론트엔드 디자인과 동기화 작업
- login & signup screens
- feed screen, Workspaces_main, Workspace_detail_screen1, paper, social, profile screens

✅ 논문 추천 섹션
- 지능형 추천을 위한 Arxiv API 통합
- 사용자 관심사 기반 추천 알고리즘 개발
- 개인화된 연구 피드 설계

✅ 포스트 기능 구현
- 포스트 생성, 조회, 수정, 삭제 API 구현
- 좋아요, 저장, 댓글 기능 구현
- 팔로우 기반 피드 조회 기능 구현

✅ 프로필 관리
- 사용자 프로필 생성 및 편집
- 프로필 이미지 업로드 및 관리
- 연구 관심사 및 자기소개 정보 관리

✅ UI/UX 개선
- 숨기기/보이기 애니메이션이 있는 개선된 내비게이션 바
- 다양한 화면 크기에 최적화된 레이아웃
- 캐시 무효화를 통한 향상된 프로필 이미지 처리

### 최근 업데이트
✅ 프로필 이미지 관리
- 프로필 이미지 업로드 기능 추가
- 즉각적인 업데이트를 위한 이미지 캐시 무효화 구현
- 도커 재시작 시 미디어 디렉토리 초기화 설정
- 프론트엔드와 백엔드 간 이미지 URL 처리 개선

✅ UI 반응성
- 앱 바와 내비게이션 바 겹침 문제 해결
- 콘텐츠 영역 크기 조정 및 위치 개선
- 화면 전환 및 애니메이션 향상

### 진행 중인 개발
🔨 Frontend detail
- 게시물 디테일 수정

🔨 리뷰 게시 시스템
- 논문 리뷰 작성/편집 페이지 개발
- 공개/비공개 리뷰 설정 구현
- 태깅 및 분류 옵션 추가

### 다음 개발 단계
1. 스크랩 및 공유 기능
- 논문 스크랩 메커니즘 구현
- 그룹 공유 인터페이스 설계
- 주석 및 하이라이트 기능 생성

### 기술적 고려사항
- 상태 관리 (Provider/Riverpod)
- 네트워크 통신 최적화
- 강화된 보안 프로토콜
- 성능 모니터링
- 오류 처리 전략

### 잠재적 과제
- API 통합 복잡성
- 확장 가능한 추천 엔진
- 크로스 플랫폼 UI 일관성
- 데이터 프라이버시 및 사용자 권한
- 구글 확장 프로그램으로 논문 검색시 관련 포스트 모아보기


## 연락처
프로젝트 관리자 - [@minji](https://www.linkedin.com/in/minhjih?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app) - jhchoi0226@snu.ac.kr

프론트엔드 협업 - [@jadestarmin](https://www.linkedin.com/in/minkyu-park-591b912b5?utm_source=share&utm_campaign=share_via&utm_content=profile&utm_medium=ios_app) - jadestar@postech.ac.kr 

프로젝트 링크: [https://github.com/minhjih/dailyexp](https://github.com/minhjih/dailyexp)
