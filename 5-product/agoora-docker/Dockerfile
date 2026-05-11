# agoora — Docker image (Phase 5 商用化 prep)
#
# Multi-stage build:
#   builder: deps install
#   runtime: 最小ランタイム (Python 3.12 slim)
#
# 起動:
#   docker compose up -d
#
# 構成:
#   - portal-api (FastAPI, port 8765)
#   - ChromaDB (volume mount /data/chroma)
#   - 静的 UI (portal-api 経由配信)
#
# tags: [agoora, docker, phase-5, production]

# === Builder stage ===
FROM python:3.12-slim AS builder

WORKDIR /build
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# === Runtime stage ===
FROM python:3.12-slim

LABEL org.opencontainers.image.title="agoora"
LABEL org.opencontainers.image.description="個人開発者の知識の集まる場 (Captain's knowledge hub)"
LABEL org.opencontainers.image.source="https://github.com/riku1215/agoora"
LABEL org.opencontainers.image.licenses="MIT"

# Locale (Japanese support)
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    PYTHONIOENCODING=UTF-8 \
    PYTHONUNBUFFERED=1 \
    PATH=/root/.local/bin:$PATH \
    PORTAL_ROOT=/data/portal \
    KB_ROOT=/data/kb

# Copy installed packages from builder
COPY --from=builder /root/.local /root/.local

# Install ripgrep (used by portal-api keyword search)
RUN apt-get update && apt-get install -y --no-install-recommends \
        ripgrep \
        ca-certificates \
        curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy agoora sources (built from project root context)
COPY 4-portal/portal-api.py /app/
COPY 4-portal/ui-template/ /app/ui-template/
COPY 4-portal/agents.yml /app/
COPY 4-portal/agent_profiles.yaml /app/
COPY 4-portal/routing.yml /app/

# Volume mounts
VOLUME ["/data/portal", "/data/kb"]

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD curl -fsS http://localhost:8765/healthz || exit 1

EXPOSE 8765

CMD ["python", "portal-api.py", "--host", "0.0.0.0", "--port", "8765"]
