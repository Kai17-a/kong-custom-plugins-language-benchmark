FROM python:3.13-slim

# 必要なツールをインストール
# RUN apt-get update && apt-get install -y --no-install-recommends curl ca-certificates
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

ADD . /app
WORKDIR /app

RUN uv sync --frozen --no-cache

EXPOSE 8000

CMD ["/app/.venv/bin/fastapi", "run", "main.py", "--port", "8000", "--host", "0.0.0.0"]
