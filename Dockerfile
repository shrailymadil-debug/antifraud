# Один образ на всю систему недели 3: сервис FastAPI, интерфейс оператора и панель мониторинга.
# Какую часть запускать, задаёт команда в docker-compose.yml.
FROM python:3.13-slim

# libgomp1 нужен LightGBM (параллельные вычисления)
RUN apt-get update && apt-get install -y --no-install-recommends libgomp1 curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
ENV PYTHONUNBUFFERED=1 PYTHONDONTWRITEBYTECODE=1

COPY requirements-docker.txt .
RUN pip install --no-cache-dir -r requirements-docker.txt

# Код и обученная модель v2 (artifacts/final_v2) + история обучения (artifacts/final/history.parquet)
COPY src ./src
COPY service ./service
COPY frontend ./frontend
COPY dashboard ./dashboard
COPY artifacts/final ./artifacts/final
COPY artifacts/final_v2 ./artifacts/final_v2
COPY score.py replay.py ./
# holdout для интерфейса; data/ при запуске подключается томом, этот файл — запасной
COPY data/holdout.csv ./data/holdout.csv

EXPOSE 8000 8501 8502
# По умолчанию — сервис
CMD ["uvicorn", "service.main:app", "--host", "0.0.0.0", "--port", "8000"]
