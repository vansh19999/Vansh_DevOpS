FROM python:3.11-slim
WORKDIR /app
COPY api/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY api/ ./api/
ENV PYTHONUNBUFFERED=1
EXPOSE 8080
CMD ["uvicorn", "api.app:APP", "--host", "0.0.0.0", "--port", "8080"]
