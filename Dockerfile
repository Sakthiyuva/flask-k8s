# Dockerfile
FROM python:3.11-slim-bullseye

WORKDIR /app
COPY . .

RUN pip install flask

CMD ["python", "main.py"]
