import os
from pathlib import Path

# 기본 디렉토리 설정
BASE_DIR = Path(__file__).resolve().parent

# 미디어 파일 저장 경로
MEDIA_DIR = os.path.join(BASE_DIR, "media")
PROFILE_IMAGES_DIR = os.path.join(MEDIA_DIR, "profile_images")

# 미디어 디렉토리가 없으면 생성
os.makedirs(MEDIA_DIR, exist_ok=True)
os.makedirs(PROFILE_IMAGES_DIR, exist_ok=True)

# 허용된 이미지 확장자
ALLOWED_IMAGE_EXTENSIONS = [".jpg", ".jpeg", ".png", ".gif"]

# 최대 이미지 크기 (5MB)
MAX_IMAGE_SIZE = 5 * 1024 * 1024 