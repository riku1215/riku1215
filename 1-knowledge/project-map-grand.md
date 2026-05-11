---
tags: [project-map, taxonomy, agoora-schema, captain-portal, master-index]
layer: knowledge
audience: [captain-only, claude, all-llms]
status: active
created: 2026-05-11
---

# riku1215 Project Map (Grand Taxonomy) — agoora 情報入力指針

`#project-map #taxonomy #agoora-schema #master-index`

> **Captain 指示反映**: 「agoora 開発には全 46 repo + 1000+ Issue を集合知として活用する。すべて記録は大変なので、大/中/小/プロジェクトマップを予め作り、agoora のシステムに情報を入れる際の指針とする」
>
> 本ドキュメントは agoora の **永続情報入力 schema**。新規 markdown / Issue を作成する際に、本マップに従って分類 + tag 付与すれば自動的に正しい位置に配置される。

## 0. メタ構造 (4 階層)

```
[L1 大分類] domain  (5 個、portal-config.yml の domain と完全一致)
   ↓
[L2 中分類] category (各 5 個、計 20+ 個)
   ↓
[L3 小分類] item     (各 5-20 個、計 100+ 個)
   ↓
[L4 ソリューション] solution (具体 project / tool / file、計 200+ 個)
```

→ frontmatter `tags:` は L1-L4 を必ず含める (例: `[ai-development, projects, agoora, ui-template]`)。

---

## 1. L1 大分類 (5 domain)

| ID | 名前 | 色 | 主要 product |
|----|------|----|----|
| **ai-development** | AI 駆動アプリ開発 | `#8B5CF6` 紫 | classweaver / mindgate / pet-care-app / ai-financial-office / agoora |
| **web-development** | Web フロント + バック | `#10B981` 緑 | quard-web-jp / kuod-hp / pet-care-app frontend |
| **data-engineering** | データ基盤・ベクトル検索 | `#3B82F6` 青 | ChromaDB / SQLite / pgvector |
| **devops** | CI/CD・監視・インフラ | `#F59E0B` 黄 | GitHub Actions / Docker / Task Scheduler |
| **business** | QUARD 経営・営業・運営 | `#EC4899` 桃 | 60 社 Dify 提案 / 青森自治体 / 監査 / 課金管理 |

---

## 2. L2-L4 完全ツリー (大 → 中 → 小 → ソリューション)

### 🤖 ai-development

#### frameworks (中分類)
| 小分類 | ソリューション (具体) |
|--------|-------------------|
| `langchain` | langchain-core, langchain-community, langgraph |
| `llama-index` | LlamaParse, LlamaCloud |
| `claude-api` | Anthropic SDK Python/TS, prompt caching, batch API |
| `openai-sdk` | OpenAI SDK, Assistants API |
| `dify` | Dify Desktop, Dify Cloud, **60 社提案実績** |
| `gemini-sdk` | Google Generative AI SDK |
| `mcp` | MCP server, FastMCP, mcp-builder skill |

#### models (中分類)
| 小分類 | ソリューション |
|--------|-------------|
| `claude` | Opus 4.x, Sonnet 4.x, Haiku 4.x |
| `gemini` | gemini-2.5-pro, gemini-2.5-flash, gemini-2.5-flash-lite |
| `chatgpt` | GPT-4.x, GPT-5 (Codex), o3-series |
| `grok` | Grok-3, Grok-4 (X 検索特化) |
| `copilot` | GitHub Copilot |
| `local-llm` | Ollama, IPEX-LLM, llamafile (Phase H) |

#### skills (中分類、47 installed)
| 小分類 | ソリューション例 |
|--------|---------------|
| `base` | mcp-builder, skill-creator, find-skills, claude-api |
| `docs` | pdf, docx, xlsx, pptx |
| `design` | frontend-design, web-design-guidelines, brand-guidelines |
| `deploy` | deploy-to-vercel, vercel-cli-with-tokens |
| `community-max4c` | grill-me, tdd, write-prd, tech-spec |
| `claude-mem` | mem-search, make-plan, smart-explore, timeline-report, pathfinder |

#### projects (中分類、agoora 主戦場)
| 小分類 (= product 名) | tier | status |
|----------------------|------|--------|
| `classweaver` | 1-mature | active (R29 calc_score↔CP-SAT) |
| `mindgate-tgl` | 1-mature | active (war-story #44) |
| `dsi-kit-library` | 1-mature | active (Phase 8、agora#40 hub) |
| `pet-care-app` | 2-active | deploy-pending (PR#52 CI) |
| `ai-financial-office` | 2-active | active |
| `ai-tool-catalog` | 2-active | active |
| `paw-sensor` | 2-active | active (autonomous-prompt-v1) |
| `agoora` | 2-active | **Phase 1 完了** |
| `shiftweaver` | 3-early | phase-0-skeleton (localhost:8000) |
| `dsi-factory` | 3-early | spec |
| `dsi-wizard` | 3-early | spec |
| `dsi-improver` | 3-early | spec |
| `doc-studio` | 3-early | spec |
| `book-studio` | 3-early | spec |
| `video-autopilot` | 3-early | spec |
| `prompt-notes` | 3-early | spec |
| `sourcecode-judge-saas` | 3-early | spec |

#### research (中分類)
| 小分類 | ソリューション |
|--------|-------------|
| `papers` | Mixed-Initiative (Horvitz 1999), Stanford Semantic Collapse |
| `x-trends` | Grok 経由 X 検索、prior-art 5 事例 |
| `kuuki-design` | 18-agent 商用組織分析 |
| `multi-llm` | R14 Claude+Gemini+ChatGPT+Grok 協調設計 |

### 🌐 web-development

#### frameworks
| 小分類 | ソリューション |
|--------|-------------|
| `nextjs` | App Router, Pages Router, RSC |
| `astro` | Astro 5.x (quard-web-jp 採用) |
| `react` | React 18, hooks, RSC |
| `vue` | Vue 3, Pinia |
| `svelte` | SvelteKit |

#### deployment
| 小分類 | ソリューション |
|--------|-------------|
| `vercel` | Production, Preview, Edge, kuod-hp.vercel.app |
| `sakura-vps` | さくら VPS (133.242.136.126)、idd53821 主運用 |
| `sakura-rental` | さくらレンタル (quard-web.jp 予定) |
| `cloudflare` | Pages, Workers, Tunnel |
| `netlify` | Production (monitor only) |
| `github-pages` | (planning) |

#### styling
| 小分類 | ソリューション |
|--------|-------------|
| `tailwind` | Tailwind CSS 3.x, JIT |
| `shadcn` | shadcn/ui Radix base |
| `quard-brand` | quard-ui design system (Phase 3) |
| `github-primer` | GitHub Primer Dark (agoora 採用) |

#### projects (web 中心)
| 小分類 | tier | status |
|--------|------|--------|
| `quard-web-jp` | 1-mature | setup (gck63819→idd53821 移行中) |
| `kuod-hp` | 2-active | active (Vercel deploy 中) |
| `masaru-suto-www` | 2-active | active (war-story #1) |
| `quard-community` | 3-early | spec |
| `quard-ui` | 3-early | spec (design system) |

### 📊 data-engineering

#### databases
| 小分類 | ソリューション |
|--------|-------------|
| `postgresql` | Postgres 16, pgvector |
| `mysql` | MySQL 8 |
| `sqlite` | SQLite (WAL + busy_timeout、feedback DB) |
| `duckdb` | DuckDB + sqlite-vec (代替候補 Issue #15) |

#### vector
| 小分類 | ソリューション |
|--------|-------------|
| `chromadb` | ChromaDB persistent client (Phase D 採用) |
| `qdrant` | Qdrant (Rust 高速、代替候補) |
| `lancedb` | LanceDB (列指向) |
| `pgvector` | pgvector (Postgres 統合) |

#### pipelines
| 小分類 | ソリューション |
|--------|-------------|
| `dbt` | dbt-core (Phase 3) |
| `airflow` | Apache Airflow (Phase 3) |

#### analytics
| 小分類 | ソリューション |
|--------|-------------|
| `grafana` | Grafana Cloud (monitor) |
| `metabase` | Metabase (monitor) |
| `bigquery` | BigQuery (GCP 整理後、Issue #7) |

### 🔧 devops

#### ci-cd
| 小分類 | ソリューション |
|--------|-------------|
| `github-actions` | auto-relay.yml (Phase 2 KPI), lint.yml, kb-issue-snapshot |
| `gitlab-ci` | (monitor) |
| `pre-commit` | (Phase 2 統合) |

#### monitoring
| 小分類 | ソリューション |
|--------|-------------|
| `datadog` | (monitor) |
| `grafana-cloud` | (monitor) |
| `self-hosted` | BurntToast (update-robust.ps1), Task Scheduler |
| `kb-stats` | Semantic Collapse 10K docs 境界監視 |

#### infrastructure
| 小分類 | ソリューション |
|--------|-------------|
| `terraform` | (monitor) |
| `ansible` | (monitor) |
| `docker` | agoora-docker (Phase 5 prep), pet-care-app |
| `kubernetes` | (Phase 5+、Helm chart) |

#### security
| 小分類 | ソリューション |
|--------|-------------|
| `secrets` | .env, GitHub Secrets (ANTHROPIC_API_KEY 等) |
| `vulnerability` | Dependabot, secret-scanning |
| `visibility` | public / local-only / captain-only 3 階層 |

### 💼 business

#### strategy
| 小分類 | ソリューション |
|--------|-------------|
| `quard-roadmap` | Phase 1-5 (agoora 含む) |
| `kuuki-imitation` | 18-agent 商用組織計画 |
| `phase-1-5` | agoora 主戦場 |
| `ai-native-mgmt` | AI ネイティブ経営 (product 候補) |

#### proposals
| 小分類 | ソリューション |
|--------|-------------|
| `dify-60-cos` | Dify 60 社提案 (Captain 実績、Section 3) |
| `aomori-jichitai` | 青森自治体提案 |
| `pet-care-demo` | pet-care デモ資料 |
| `agoora-pitch` | agoora SaaS pitch (Phase 5) |

#### audit
| 小分類 | ソリューション |
|--------|-------------|
| `aomori-jumin` | 青森住民監査請求 (2026-04-23 提出済) |
| `aba-media` | ABA 朝日放送ほか |

#### billing
| 小分類 | 状態 |
|--------|------|
| `rakuten` | ¥69,240/月 |
| `paypay` | ¥83,494/月 |
| `lopital` | ¥0 (2026-05-10 解約済) |
| `gcp` | pending closure (Issue #7) |
| `sakura` | 重複整理待ち |

---

## 3. プロジェクトマップ (relations、Cytoscape 互換)

### 中央ノード = agoora

```
                              [agora] (R-rules, 1000+ Issue、parent)
                                  ↑
                                  ↑ inherits
                                  │
[claude-mem skills] → [agoora] ← [agents.yml (7+ 役)]
                          │
       ┌──────────────────┼──────────────────┐
       ↓                  ↓                  ↓
   [~/.kb/ 46 repo]   [ChromaDB]      [GitHub Actions]
       │                  │                  │
   [Phase A-G]        [Phase D]          [auto-relay]
       │                                     │
       └──→ [Tree-sitter PoC] → [impact-analyst] → [reviewer]
                                                     │
                                                     ↓
                                              [Captain 承認]
                                                     │
                                                     ↓
                                              [Issue update / PR]
```

### Tier 別 product 接続

```
[Tier 1 mature]
  ├─ agora            (R-rules、parent of agoora)
  ├─ classweaver      (R29 calc_score↔CP-SAT 知見)
  ├─ mindgate-tgl     (war-story #44 deploy 落とし穴 9)
  └─ dsi-kit-library  (cross-repo knowledge hub)
                  ↓ knowledge transfer (agora#40 Tier 1→2,3)
[Tier 2 active]
  ├─ pet-care-app    (DSI 適用第 1 号、PR#52 blocking)
  ├─ ai-financial-office
  ├─ paw-sensor      (autonomous-prompt-v1)
  ├─ ai-tool-catalog
  ├─ kuod-hp
  ├─ masaru-suto-www
  └─ agoora ★ (本 product)
                  ↓ pattern transfer
[Tier 3 early]
  ├─ shiftweaver, dsi-factory/wizard/improver
  ├─ doc-studio, book-studio, video-autopilot
  ├─ prompt-notes, sourcecode-judge-saas
  └─ quard-community, quard-ui
```

---

## 4. agoora への情報入力指針 (本マップの使い方)

### 新規 markdown 作成時

1. **L1 大分類** を必ず frontmatter `tags:` の最初に: `tags: [ai-development, ...]`
2. **L2 中分類** を 2 番目に: `tags: [ai-development, projects, ...]`
3. **L3 小分類** を 3 番目に: `tags: [ai-development, projects, agoora, ...]`
4. **追加 tag** で具体性: `tags: [ai-development, projects, agoora, ui-template, github-ia]`

### 新規 Issue 作成時 (agora label taxonomy 準拠)

```yaml
# Frontmatter
tags: [<L1>, <L2>, <L3>, <feature>]

# GitHub labels
- type:<doc|milestone|research|decision|retro|epic|strategy|refactor>
- area:<llm|arch|test|ops|ui|infra-runtime|algorithm|data|integration>
- phase:<00-09>
- status:<done> (完了後付与)
- priority:<p0> (critical のみ)
- agent:<claude|gemini|grok|chatgpt> (発議元)
- doctrine:<must|instruction> (R-rule 候補)
- visibility:<public|local-only|captain-only>
```

### portal-init.ps1 / build-indexes.ps1 が自動処理

- L1-L4 tag → graph.json のクラスター
- visibility tag → 公開フィルタ
- type/area tag → tab 分類

### ハッシュタグ命名規約

- 単語小文字、ハイフン区切り (例: `#1-issue-relay`、`#tree-sitter`、`#agoora`)
- 大文字混在禁止
- product 名は単独で OK (例: `#agoora`、`#classweaver`)

---

## 5. グランドマップ統計 (本 doc 時点)

| 階層 | 件数 |
|------|------|
| L1 大分類 | 5 |
| L2 中分類 | 22 |
| L3 小分類 (具体技術 / project) | 90+ |
| L4 ソリューション (具体 file / tool) | 200+ |
| **agora R-rule** | 50+ (7 doctrine cluster) |
| **agora labels** | 65 unique |
| **47 skills** | 47 (Anthropic / Vercel / max4c / thedotmack) |
| **GitHub repos** | 46 (riku1215 全体) |
| **GitHub Issues** | 1000+ (~/.kb/issues/) |

---

## 6. 次のアクション (agoora 開発継続のため)

1. **dsi-kit-library 調査** ([riku1215/dsi-kit-library/issues](https://github.com/riku1215/dsi-kit-library/issues))
   → agora#40 / #194 で言及される「新規 PJ 立ち上げ完全自動化 stack」を本マップに反映

2. **skills-strategy-analysis 調査** ([riku1215/skills-strategy-analysis](https://github.com/riku1215/skills-strategy-analysis))
   → 47 skills の戦略分析結果を agents.yml 各役の skill 割当に反映

3. **全 46 repo の Issue 集合分析** (Phase 2 で本マップを使って絞り込み):
   - 各 repo を L3 小分類のどこに位置付けるか確定
   - tier 1/2/3 を明確化
   - blocking dependency を可視化

4. **agoora の検索 UI で本マップを drill-down navigation 化**:
   - 1-domains/ 配下の per-domain CLAUDE.md と接続
   - Cytoscape graph で relations 表示
   - search bar から L1-L4 tag 検索

---

## 7. 関連

- `4-portal/portal-config.yml` quard_products 25 個 (本マップの実装版)
- `3-rules/r-rules-index.md` (R-rules 大分類)
- `3-rules/agora-labels-audit.md` (agora 65 labels)
- `1-knowledge/usability-feedback-2026-05-11.md` (R83-R87 提案)
- `1-knowledge/prior-art-2026-05-11.md` (Grok 5 事例)
- [agora#40](https://github.com/riku1215/agora/issues/40) Cross-Repo Knowledge Transfer
- [agora#82](https://github.com/riku1215/agora/issues/82) R-rule 7 doctrine cluster

`#project-map #taxonomy #agoora-schema #master-index #grand-taxonomy`
