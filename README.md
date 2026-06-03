# company-brain

Internal organizational-memory substrate for NexTrial AI. A **bi-temporal, four-graph** knowledge store that ingests signals from company tools (email, docs, chat, project, analytics), classifies them with an LLM, links them into a graph, and **answers natural-language questions** about them — grounded in that graph.

> ### ⚠️ Boundary — read first
> `company-brain` is **internal company infrastructure**, NOT the NexTrial clinical product (Celina / RLM / SPEO / CFM-1 / PPEE). Separate GCP project, identity, and security domain. Keep that line absolute — in code, naming, and docs.

---

## What it does

1. **Connectors** read curated signals from sources (Gmail label, Drive folder; more planned) and publish to one Pub/Sub bus. They never touch the brain directly.
2. **Worker** drains the bus and **classifies** each signal with Gemini (on Vertex) into a typed graph node.
3. **Graph** links nodes across four orthogonal graphs (semantic, entity, temporal, causal), bi-temporally — nothing is hard-deleted; updates supersede.
4. **Query agent** answers questions ("what's the latest on the X partnership?") by calling read-only graph tools and synthesizing an answer with a swappable LLM.

## Architecture

```
 Connectors (publish only)              Sealed brain (internal-ingress)
 ┌────────────────────────┐
 │ Gmail poller (DWD)      │─┐
 │ Drive poller (DWD)      │ │   ┌──────────────┐   ┌──────────────────┐
 │ Slack/Plane/PostHog *   │ ├──▶│ brain-signals │──▶│ worker (Job, */15)│
 └────────────────────────┘ │   │  (Pub/Sub bus)│   │ pull → classify   │
                             │   └──────────────┘   └─────────┬─────────┘
                             │                       Gemini (Vertex, ADC)
                             │                                 ▼
   FastAPI service ──────────┘                       ┌──────────────────┐
   (internal, IAM-only)                              │ Cloud SQL (PG)   │
   /ask  /lineage  /nodes ...                        │ bi-temporal,     │
        │                                            │ four-graph       │
        ▼  query agent                               └──────────────────┘
   ModelProvider (claude|gemini|kimi, via Vertex/ADC)
        └─ read-only graph tools (search, neighbors, lineage)
   * Slack/Plane/PostHog planned.
```

**Core principle:** connectors only *publish* to the bus; nothing external calls the brain. The API is internal-ingress + IAM-only. The worker writes via shared code + direct DB (no VPC hop).

## Data model

Tables `nodes`, `edges`, `signals` (`app/db.py`), all bi-temporal + soft-delete.
- `NodeType`: `PERSON, COMPANY, DEAL, SIGNAL, DECISION, ARTIFACT, CONCEPT`
- `GraphType`: `SEMANTIC, ENTITY, TEMPORAL, CAUSAL`
- `Status`: `ACTIVE, SUPERSEDED`
- `SignalSource`: `GMAIL, SLACK, GDRIVE, PLANE, POSTHOG, MANUAL`
- Bi-temporal: `valid_from/valid_to/recorded_at/superseded_by`. **Soft-delete = SUPERSEDED**; lineage excludes superseded edges.

## API surface (internal-ingress)

| Method · Path | Purpose |
|---|---|
| `POST /ask` | **Query agent** — NL question → grounded answer + source node ids |
| `POST /signals/ingest` · `POST /signals/{id}/process` | ingest + classify |
| `GET /nodes` · `GET /nodes/{id}` · `DELETE /nodes/{id}` | read / soft-delete nodes |
| `GET /edges` · `DELETE /edges/{id}` | read / soft-delete edges |
| `GET /graph/{graph_name}` | one of the four graphs |
| `GET /lineage/{node_id}` | recursive causal/temporal walk |

Ingest+classify logic lives once in `app/ingestion_service.py`; lineage logic once in `app/services/query_service.py`. Routes are thin callers.

## Connectors (live)

Same pattern: authenticate to a source, publish `{"source":<X>,"raw_payload":{…}}` to `brain-signals`, advance a GCS checkpoint **only after** a successful publish. Keyless Domain-Wide Delegation (no JSON keys); read-only scopes; each runs as its own single-purpose SA.

- **Gmail** — `app/connectors/gmail_poller.py`. Polls `steven@nextrial.ai` for **`brain`-labeled** mail (`gmail.readonly`). Runs as `gmail-connector`.
- **Drive** — `app/connectors/drive_poller.py`. Polls the **`brain` folder** for Google Docs (`drive.readonly`), exports to text. Runs as `drive-connector`. (Docs only in v0; PDFs/Sheets/Slides deferred.)

## Interaction layer — the query agent (live)

`app/agent/` + `/ask`. A bounded tool-use loop: the model calls **read-only** graph tools (`search_nodes`, `get_node`, `get_neighbors`, `get_lineage`) and synthesizes a grounded answer. Neutral company-memory analyst — no personas, no fabrication.

- **Swappable models** behind `ModelProvider` (`AGENT_MODEL` env): **Claude Sonnet 4.6**, **Gemini**, **Kimi K2 Thinking** — all via **Vertex AI, keyless ADC, no external API keys**. Each provider owns its own SDK/tool-format translation; the loop is provider-agnostic.
- **Gemini is the proven default**; Claude and Kimi require a one-time Model Garden enable to join the rotation.
- Bounded at `MAX_ROUNDS=5`. Citations populate from tool *results*.

## Infrastructure (GCP)

Project **`company-brain-498101`** (`494166823052`), region **`us-central1`** (Kimi uses `global`).

| Resource | Name |
|---|---|
| Cloud Run service | `company-brain` (internal ingress) |
| Cloud Run Jobs | `company-brain-worker`, `gmail-poller`, `drive-poller` |
| Cloud Scheduler | `company-brain-worker-trigger`, `gmail-poller-trigger`, `drive-poller-trigger` |
| Cloud SQL (PG 15) | `company-brain-pg` (`db-g1-small`) |
| Pub/Sub | `brain-signals` / `brain-signals-sub` |
| GCS | `company-brain-498101-gmail-checkpoint` (gmail/ + drive/ prefixes) |
| Secret Manager | `company-brain-db-pass`, `company-brain-database-url` |
| Vertex AI | `gemini-2.5-flash-lite` (classifier); Claude/Gemini/Kimi (agent) |

**Service accounts (least privilege):**
- `company-brain-run` — service + worker + agent. `cloudsql.client`, `secretmanager.secretAccessor`, `aiplatform.user`, `pubsub.subscriber`, `run.invoker`.
- `gmail-connector` / `drive-connector` — one per source. `iam.serviceAccountTokenCreator` (self, keyless DWD), `pubsub.publisher` (brain-signals), `storage.objectUser` (checkpoint bucket). DWD authorized for the respective readonly scope.

**Enabled APIs include:** `aiplatform`, `pubsub`, `cloudscheduler`, `iamcredentials`, `gmail`, `drive`, `run`, `sqladmin`, `secretmanager`, `storage`.

**Org policy note:** `iam.allowedPolicyMemberDomains` (Domain Restricted Sharing) is active — it blocks the external Gmail-push SA, which is why connectors **poll** rather than use push (ADR-017).

## Architecture Decision Records (company-brain series)

| # | Decision | Rationale |
|---|---|---|
| 001 | Cloud SQL not AlloyDB | cheapest-that-works, schema portable |
| 002 | Internal ingress + IAM-only | never public |
| 003 | Secrets in Secret Manager; no keys on disk | |
| 004 | Least-privilege SAs | no `roles/editor` |
| 005 | Single `DATABASE_URL` (socket form) | |
| 006 | Soft-delete = SUPERSEDED | history is load-bearing |
| 007 | Bi-temporal model | |
| 008 | Four-graph edge model | |
| 009 | Lineage excludes superseded edges | |
| 010 | Gemini Flash-Lite for classification | cheap, high-volume; behind `ClassifierInterface` |
| 011 | Vertex via ADC, no keys | |
| 012 | Stub classifier fallback | never crash ingestion |
| 013 | Single ingest+process service path | |
| 014 | Pub/Sub bus; connectors publish only | sealed brain |
| 015 | Pull (not push) consumption | nothing inbound to the brain |
| 016 | Worker writes via shared code + direct DB | no VPC |
| 017 | Connectors poll, not push | org policy blocks external push SA; latency irrelevant |
| 018 | Keyless DWD (signJwt) | no JSON keys |
| 019 | One dedicated SA per connector | blast-radius isolation |
| 020 | Curated scope (Gmail label / Drive folder) | low-noise, human decides what's remembered |
| 021 | Drive v0 = Google Docs only, folder-scoped | simple first cut; binaries deferred |
| 022 | Query agent is **read-only** over the graph | answers, never mutates memory |
| 023 | `ModelProvider` swap seam; loop provider-agnostic | A/B + future flexibility, proven by 3 real providers |
| 024 | Agent models via Vertex, keyless (incl. Kimi MaaS, not Moonshot key) | no external keys for inference; data stays in-GCP |
| 025 | Gemini = default working agent model | Claude/Kimi gated on Model Garden enable |
| 026 | Bounded agent loop (`MAX_ROUNDS=5`) | no runaway tool loops / cost |

## Deferred (intentional)

- Connectors: **Plane**, Slack, PostHog (same poller shape).
- Drive: PDFs / Sheets / Slides extraction (v1).
- Interaction: Slack / email adapters (call `/ask`); A/B harness across providers.
- Agent: enable Claude Sonnet 4.6 + Kimi K2 Thinking in Model Garden for the full rotation; deploy `/ask` to the cloud service (currently proven locally).
- Hardening: AlloyDB, multi-region, RLS namespaces, private-IP Cloud SQL, low-latency worker.

## Local dev & deploy

Tests (need Postgres binaries): `sudo apt-get install -y postgresql`; `export PATH="$(ls -d /usr/lib/postgresql/*/bin|tail -1):$PATH"`; `pip install -r requirements.txt`; `PYTHONPATH=. python -m pytest -q`.

Verify against cloud DB: `cloud-sql-proxy <conn>` then point `DATABASE_URL` at `127.0.0.1:5432`, `alembic upgrade head`, `uvicorn app.main:app`.

Deploy service (also rebuilds the image the Jobs reuse): `gcloud run deploy company-brain --source . --ingress internal --no-allow-unauthenticated …` (see infra inventory for SA/secret/env).

See `AGENTS.md` for how changes are made here.
