# CP2 — Production-ready container for the Day 12 FastAPI agent.

FROM python:3.11-slim AS builder

WORKDIR /build

# Copy dependency manifest first so this expensive layer stays cached
# when only application source code changes.
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


FROM python:3.11-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

WORKDIR /app

# Bring only installed Python dependencies from the builder stage.
COPY --from=builder /install /usr/local

# Copy runtime source after dependencies to preserve Docker layer caching.
COPY app ./app
COPY utils ./utils

# Run the service as an unprivileged user instead of root.
RUN useradd --create-home --uid 10001 appuser \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

# /health is a liveness endpoint and intentionally does not depend on Redis.
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD python -c "import os, urllib.request; urllib.request.urlopen('http://127.0.0.1:' + os.getenv('PORT', '8000') + '/health', timeout=3)" || exit 1

# Shell form is intentional here so the cloud-provided PORT is expanded.
CMD ["sh", "-c", "exec uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
