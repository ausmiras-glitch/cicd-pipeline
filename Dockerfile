# syntax=docker/dockerfile:1
FROM python:3.12-slim

# AWS Lambda Web Adapter: lets this same image run on Lambda unchanged.
# It is ignored when the container runs anywhere else (Docker, ECS, etc.).
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080 \
    AWS_LWA_READINESS_CHECK_PATH=/health

WORKDIR /srv

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app ./app

ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/health')"

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8080"]
