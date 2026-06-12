# FixImageScan

Reusable local workflow for building a Docker image, scanning it for CVEs, and iterating on the Dockerfile until the risk is understood or fixed.

## What This Gives You

- Dockerfile linting with Hadolint
- Image vulnerability scanning with Trivy
- SBOM generation with Syft
- SBOM vulnerability cross-checking with Grype
- Repeatable local commands that can also be copied into CI
- JSON/SARIF reports under `security/reports/`

The scripts prefer locally installed tools. If a tool is missing, they fall back to the official Docker images for that tool.

## Requirements

Minimum:

- Docker
- Bash

Recommended:

- `make`
- `trivy`
- `syft`
- `grype`
- `hadolint`

If you do not install the scanner CLIs locally, Docker will pull:

- `aquasec/trivy:latest`
- `anchore/syft:latest`
- `anchore/grype:latest`
- `hadolint/hadolint:latest`

## Quick Start

Put your `Dockerfile` in this repo, then run:

```bash
make scan
```

If `make` is not installed:

```bash
scripts/cve-scan.sh scan
```

By default this builds:

```text
IMAGE=local/cve-test:latest
DOCKERFILE=Dockerfile
CONTEXT=.
SEVERITY=HIGH,CRITICAL
IGNORE_UNFIXED=true
```

## Common Commands

Build only:

```bash
make build
```

Lint Dockerfile only:

```bash
make lint
```

Scan an already-built image with Trivy:

```bash
BUILD=false RUN_GRYPE=false IMAGE=myapp:cve-test scripts/cve-scan.sh trivy
```

Generate SBOM only:

```bash
IMAGE=myapp:cve-test scripts/cve-scan.sh sbom
```

Scan SBOM with Grype:

```bash
IMAGE=myapp:cve-test scripts/cve-scan.sh grype
```

Use a custom Dockerfile and image name:

```bash
make scan IMAGE=myapp:cve-test DOCKERFILE=docker/Dockerfile CONTEXT=.
```

Relax the severity gate temporarily:

```bash
make scan SEVERITY=CRITICAL
```

Include unfixed vulnerabilities in the fail gate:

```bash
make scan IGNORE_UNFIXED=false
```

## Reports

Generated files:

```text
security/reports/image-trivy.json
security/reports/image-trivy.sarif
security/reports/sbom.spdx.json
security/reports/image-grype.json
```

Reports are ignored by Git by default. Keep selected reports manually if you want an audit trail.

## Fix Loop

Use this order when the scan finds CVEs:

1. Update the base image tag to a newer patch version.
2. Remove unnecessary OS packages, build tools, and language dependencies.
3. Use multi-stage builds so compilers and package managers do not ship in the final runtime image.
4. Update application lockfiles such as `package-lock.json`, `poetry.lock`, `requirements.txt`, `go.sum`, or Maven/Gradle lock metadata.
5. Rebuild and rerun `make scan`.
6. Add ignores only for documented false positives or accepted risk.

Temporary Trivy exceptions go in:

```text
security/.trivyignore
```

Temporary Grype exceptions go in:

```text
security/.grype.yaml
```

Keep ignore entries tied to an issue, owner, and review date.
