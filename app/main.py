"""Dummy web service deployed by the CI/CD pipeline."""

import os
import platform
from datetime import UTC, datetime

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

APP_VERSION = os.getenv("APP_VERSION", "dev")
STARTED_AT = datetime.now(UTC)

app = FastAPI(title="cicd-pipeline", version=APP_VERSION)


class EchoRequest(BaseModel):
    message: str


@app.get("/")
def root() -> dict:
    return {
        "service": "cicd-pipeline",
        "message": "Deployed automatically by GitHub Actions",
        "version": APP_VERSION,
    }


@app.get("/health")
def health() -> dict:
    return {"status": "ok"}


@app.get("/version")
def version() -> dict:
    return {
        "version": APP_VERSION,
        "python": platform.python_version(),
        "started_at": STARTED_AT.isoformat(),
    }


@app.post("/echo")
def echo(body: EchoRequest) -> dict:
    text = body.message.strip()
    if not text:
        raise HTTPException(status_code=422, detail="message must not be blank")
    return {"echo": text, "length": len(text)}
