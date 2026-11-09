# Inception — Documentation

Technical documentation for the Inception infrastructure — a containerized LEMP stack running WordPress, MariaDB, PHP-FPM, NGINX, Redis, and several auxiliary services, all orchestrated with Docker Compose.

| Document | Description |
|---|---|
| [`../EXPLANATION.md`](../EXPLANATION.md) | Storybook guide explaining the entire kingdom, all 8 services, and core concepts with child-friendly tales and usage stories. |
| [`EVALUATION_QA.md`](./EVALUATION_QA.md) | Peer evaluation defense guide: answers to all evaluation questions, proofs, commands, and child analogies. |
| [`ARCHITECTURE.md`](./ARCHITECTURE.md) | System architecture diagrams, inter-service communication matrix, Docker networking internals, volume and secrets layout. |
| [`IMPLEMENTATION.md`](./IMPLEMENTATION.md) | Per-service deep dive: every Dockerfile, configuration file, and entrypoint script explained in detail. |
| [`REFERENCE.md`](./REFERENCE.md) | Concept guide covering Docker, containers, images, networking, TLS, persistence, and all major design decisions with full technical explanations. |
| [`COMMANDS.md`](./COMMANDS.md) | Operational command reference for managing, inspecting, and verifying the running infrastructure. |

## Recommended Reading Order

1. **ARCHITECTURE.md** — understand how all services connect
2. **IMPLEMENTATION.md** — understand what each service's code does
3. **REFERENCE.md** — understand the underlying concepts and design decisions
4. **COMMANDS.md** — operational reference for day-to-day use
