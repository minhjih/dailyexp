FROM python:3.9-slim

WORKDIR /app

COPY ./requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app /app
COPY ./start.sh /app/start.sh

# 스크립트에 실행 권한 부여
RUN chmod +x /app/start.sh

# 데이터베이스 대기 스크립트 추가
COPY ./wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

CMD ["./wait-for-it.sh", "db:5432", "--", "sh", "/app/start.sh"] 