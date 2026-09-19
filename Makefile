.PHONY: install lint format test run docker-build docker-run

install:
	python3 -m venv .venv && .venv/bin/pip install -r requirements-dev.txt

lint:
	.venv/bin/ruff check . && .venv/bin/ruff format --check .

format:
	.venv/bin/ruff check --fix . && .venv/bin/ruff format .

test:
	.venv/bin/pytest --cov=app --cov-fail-under=90

run:
	.venv/bin/uvicorn app.main:app --reload --port 8080

docker-build:
	docker build -t cicd-pipeline:local .

docker-run:
	docker compose up --build
