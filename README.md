# ml-platform

LLM fine-tuning and serving platform. Submit a fine-tuning job via API, train a LoRA adapter with FSDP, evaluate with a judge model, register the artifact, and serve it with vLLM multi-LoRA — with canary routing and observability.

## Architecture

```
User → REST API (grpc-gateway) → Go control plane → gRPC → Python compute (training/serving)
                                       │
                                       ├── PostgreSQL (state)
                                       ├── Redis (cache/queue)
                                       ├── MinIO (artifacts)
                                       └── go-taskqueue (job orchestration)
```

| Layer | Technology |
|-------|-----------|
| Control plane | Go 1.22+, gRPC, grpc-gateway, sqlc, goose |
| Task queue | [go-taskqueue](https://github.com/tradaokamsa/go-taskqueue) (separate microservice) |
| Training | Python 3.12, PyTorch, HuggingFace, PEFT, FSDP, TRL |
| Serving | vLLM, FastAPI, multi-LoRA |
| Evaluation | lm-eval-harness, judge model |
| Storage | PostgreSQL 16, Redis 7, MinIO |
| Orchestration | Kubernetes, Helm/Kustomize, kubebuilder |
| Observability | OpenTelemetry, Prometheus, Grafana, Jaeger |
| CI/CD | GitHub Actions, GHCR, buf |

## Project Structure

```
ml-platform/
├── proto/                    # gRPC service definitions
│   └── training/v1/
├── go-control-plane/         # Go services
│   ├── cmd/                  # Entry points (experiment-manager, registry, router)
│   ├── internal/             # Business logic, DB, gRPC stubs
│   └── migrations/           # SQL migrations (goose)
├── python-compute/           # ML workloads (training, serving, eval)
├── deploy/                   # Dockerfiles, k8s manifests, Grafana dashboards
└── docs/                     # Architecture docs, ADRs, runbook
```

## Prerequisites

- Go 1.22+
- Python 3.12+
- Docker & Docker Compose
- [buf](https://buf.build/) (`brew install bufbuild/buf/buf`)
- [goose](https://github.com/pressly/goose) (`go install github.com/pressly/goose/v3/cmd/goose@latest`)
- [sqlc](https://sqlc.dev/) (`go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest`)
- [grpcurl](https://github.com/fullstorydev/grpcurl) (`brew install grpcurl`)

## Quick Start

```bash
# 1. Start infrastructure (Postgres, Redis, MinIO, go-taskqueue)
make infra

# 2. Run database migrations
make migrate

# 3. Generate code from proto and SQL definitions
make proto
make sqlc

# 4. Build
make build

# 5. Run the experiment manager
make run
```

Verify the server is running:

```bash
grpcurl -plaintext localhost:9090 list
```

## Makefile Targets

| Command | Description |
|---------|-------------|
| `make infra` | Start infrastructure services |
| `make infra-down` | Stop infrastructure services |
| `make migrate` | Apply database migrations |
| `make migrate-status` | Check migration status |
| `make proto` | Generate Go code from .proto files |
| `make sqlc` | Generate Go code from SQL queries |
| `make build` | Compile Go binaries |
| `make run` | Start the experiment-manager gRPC server |

## Related Repositories

- [go-taskqueue](https://github.com/tradaokamsa/go-taskqueue) — Redis-backed task queue microservice with priority, retry, and reaper
