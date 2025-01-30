from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import papers, auth, scraps, groups, comments, profile
from .models.database import init_db
import uvicorn

app = FastAPI(title="DailyExp API")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포 시에는 구체적인 도메인으로 변경
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
    except Exception as e:
        print(f"Database initialization error: {e}")

app.include_router(auth.router)
app.include_router(papers.router)
app.include_router(scraps.router)
app.include_router(groups.router)
app.include_router(comments.router)
app.include_router(profile.router)

@app.get("/")
async def root():
    return {"message": "Welcome to DailyExp API"} 