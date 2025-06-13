# Dockerfile
FROM python:3.10-slim-bookworm

WORKDIR /app
COPY . .

RUN pip install flask

CMD ["python", "main.py"]
