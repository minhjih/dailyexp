from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from .routers import papers, auth, scraps, groups, comments, profile, workspaces, posts, users
from .models.database import init_db, engine, Base
from .config import MEDIA_DIR
import uvicorn
import os

app = FastAPI(
    title="DailyExp API",
    description="DailyExp 애플리케이션을 위한 API",
    version="0.1.0",
    redirect_slashes=False,
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포 시에는 특정 도메인으로 제한해야 함
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 앱 시작 시 데이터베이스 초기화
@app.on_event("startup")
async def startup_event():
    try:
        from .models.database import init_db
        init_db()
        Base.metadata.create_all(bind=engine)
    except Exception as e:
        print(f"Database initialization error: {e}")

app.include_router(auth.router)
app.include_router(papers.router)
app.include_router(scraps.router)
app.include_router(groups.router)
app.include_router(comments.router)
app.include_router(profile.router)
app.include_router(workspaces.router)
app.include_router(posts.router)
app.include_router(users.router)

# 정적 파일 제공 설정
# 미디어 디렉토리가 없으면 생성
os.makedirs(MEDIA_DIR, exist_ok=True)
app.mount("/media", StaticFiles(directory=MEDIA_DIR), name="media")

@app.get("/")
async def root():
    return {"message": "Welcome to DailyExp API"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"} 