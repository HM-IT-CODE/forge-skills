---
name: dockerize
description: Generates a production-grade, multi-stage Dockerfile and docker-compose for a project. Use when the user says "dockerize", "containerize this", "write a Dockerfile", "add Docker", or wants to package a service for deployment. Detects the stack and applies small-image, non-root, layer-caching best practices.
---

# Dockerize

Produce a Dockerfile a platform team would approve: small, secure, reproducible, and fast to rebuild. Never a single fat `FROM language` with the whole repo copied in.

## Step 1 — Detect the stack

Inspect the repo to determine language, build tool, and run command:

- **Node/TS:** `package.json` (scripts, `engines`), lockfile (`pnpm-lock.yaml` / `package-lock.json` / `yarn.lock`).
- **Python:** `pyproject.toml` / `requirements.txt`, entry module.
- **Rust:** `Cargo.toml`, binary name from `[[bin]]` or package name.
- **Go:** `go.mod`, `main` package path.

Confirm the detected build and start commands. If ambiguous, ask.

## Step 2 — Write a multi-stage Dockerfile

Always use multi-stage builds: a **builder** stage with the toolchain, and a minimal **runtime** stage that copies only the artifact.

Apply these rules in every Dockerfile:

- **Pin** the base image to a specific minor + variant (e.g. `node:22-slim`, `python:3.12-slim`, `rust:1.79`, `golang:1.22`). Avoid `latest`.
- **Order layers for cache:** copy dependency manifests and install deps *before* copying source, so code changes don't bust the dependency layer.
- **Minimal runtime base:** `distroless`, `alpine`, `-slim`, or `scratch` (Go/Rust static binaries).
- **Run as non-root:** create and switch to an unprivileged user.
- **No secrets in layers.** Use build args / runtime env, never bake credentials.
- Add a `HEALTHCHECK` when the service exposes a port.
- Set `EXPOSE`, a sensible `WORKDIR`, and an explicit `CMD` (exec form, JSON array).

### Reference shape (Rust static binary)

```dockerfile
# ---- builder ----
FROM rust:1.79-slim AS builder
WORKDIR /app
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs && cargo build --release && rm -rf src
COPY . .
RUN cargo build --release

# ---- runtime ----
FROM gcr.io/distroless/cc-debian12
COPY --from=builder /app/target/release/<binary> /usr/local/bin/app
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/app"]
```

Adapt the same two-stage pattern to whatever stack you detected.

## Step 3 — Add .dockerignore

Generate a `.dockerignore` that excludes build artifacts and local junk so the build context stays small:

```
.git
target/
node_modules/
dist/
**/*.log
.env*
```

## Step 4 — docker-compose (if it helps)

If the service needs a database or other dependency, generate a `docker-compose.yml` wiring the app to its dependencies with named volumes, a healthcheck-gated `depends_on`, and env passed via `environment` / `.env`. Keep it self-hostable with one `docker compose up`.

## Step 5 — Verify

Show the user the `docker build` command and, where possible, note the expected final image size order of magnitude. Point out anything stack-specific they should tune (e.g. multi-arch builds, build secrets). Do not run pushes to any registry.
