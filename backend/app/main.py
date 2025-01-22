from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from .routers import papers, auth

app = FastAPI(title="DailyExp API")

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 실제 배포 시에는 구체적인 도메인으로 변경
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(papers.router)

@app.get("/")
async def root():
    return {"message": "Welcome to DailyExp API"} 