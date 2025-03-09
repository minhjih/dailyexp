#!/bin/bash

# media 폴더 초기화
echo "Cleaning media directory..."
rm -rf /app/app/media/*
mkdir -p /app/app/media/profile_images

# FastAPI 애플리케이션 실행
echo "Starting FastAPI application..."
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload 