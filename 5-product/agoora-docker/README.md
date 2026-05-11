# 5-product/agoora-docker/ — Docker 化 (Phase 5 商用化 prep)

`#agoora #docker #phase-5 #commercial`

## 役割

agoora を **Docker container** として packaging。Captain Windows での再現性向上 + Phase 5 で SaaS deploy 基盤。

## クイックスタート (Captain Windows)

```powershell
# 1. Docker Desktop 起動
# 2. リポ移動
cd $env:USERPROFILE\work\agoora

# 3. (初回のみ) build
docker compose -f 5-product\agoora-docker\docker-compose.yml build

# 4. 起動
docker compose -f 5-product\agoora-docker\docker-compose.yml up -d

# 5. ブラウザで開く
Start-Process "http://localhost:8765/"

# 6. ログ確認
docker compose -f 5-product\agoora-docker\docker-compose.yml logs -f
```

## ファイル構成

| ファイル | 役割 |
|---------|------|
| `Dockerfile` | Multi-stage build (builder + runtime、Python 3.12 slim ベース) |
| `docker-compose.yml` | 1 service (agoora、port 8765 localhost bind) |
| `requirements.txt` | fastapi / uvicorn / chromadb / anthropic / pyyaml / requests / ripgrep |
| `README.md` | 本ファイル |

## 環境変数

| Env | 必須 | 用途 |
|-----|------|------|
| `PORTAL_ROOT` | 自動 | `/data/portal` (volume) |
| `KB_ROOT` | 自動 | `/data/kb` (volume) |
| `PORTAL_HOST_PATH` | 任意 | `~/Portal` default、Windows は `$env:USERPROFILE\Portal` |
| `KB_HOST_PATH` | 任意 | `~/.kb` default |
| `ANTHROPIC_API_KEY` | 任意 | auto-relay 統合時 |
| `GEMINI_API_KEY` | 任意 | critic agent (R14 echo chamber 防止) |

## Healthcheck

`GET /healthz` で 30 秒間隔チェック。3 回失敗で unhealthy 判定。

## Phase 5 商用化への布石

| Phase | 拡張 |
|-------|------|
| 5.0 | 本 Dockerfile を agoora.jp / agora.quard-web.jp で deploy |
| 5.1 | Postgres + Redis 統合 (compose 内 commented out) |
| 5.2 | GitHub Container Registry (`ghcr.io/riku1215/agoora:v1.0`) |
| 5.3 | k8s Helm chart (法人版 SaaS) |
| 5.4 | Stripe billing integration |

## Security

- ✓ port は `127.0.0.1:8765` のみ bind (localhost 外公開なし)
- ✓ volumes は **read-only** (`:ro`)、container 内から host 改変不可
- ✓ Healthcheck で異常検出時 docker restart
- ✓ Captain 環境では Docker Desktop が認証層
- Phase 5: 外部公開時は Cloudflare Tunnel / Tailscale 経由推奨

## 関連

- `4-portal/portal-api.py` — 本 image のエントリポイント
- `4-portal/ui-template/` — 静的 UI assets
- `4-portal/agents.yml` / `agent_profiles.yaml` / `routing.yml` — ハーネス定義
- [Phase 5 ロードマップ (portal-config.yml roadmap section)](../../4-portal/portal-config.yml)
- [riku1215/riku1215 PR #19](https://github.com/riku1215/riku1215/pull/19)
