IMAGE ?= local/cve-test:latest
DOCKERFILE ?= Dockerfile
CONTEXT ?= .
REPORT_DIR ?= security/reports
SEVERITY ?= HIGH,CRITICAL
IGNORE_UNFIXED ?= true
RUN_GRYPE ?= true
BUILD ?= true

.PHONY: help build lint scan scan-trivy scan-grype sbom clean-reports

help:
	@printf '%s\n' \
		'Targets:' \
		'  make scan        Build, lint, scan with Trivy, and optionally scan SBOM with Grype' \
		'  make build       Build the Docker image' \
		'  make lint        Lint the Dockerfile with Hadolint' \
		'  make scan-trivy  Scan the image with Trivy' \
		'  make scan-grype  Generate SBOM with Syft and scan it with Grype' \
		'  make sbom        Generate an SPDX JSON SBOM with Syft' \
		'  make clean-reports' \
		'' \
		'Common overrides:' \
		'  IMAGE=myapp:cve-test DOCKERFILE=./Dockerfile CONTEXT=. SEVERITY=HIGH,CRITICAL'

build:
	docker build -f "$(DOCKERFILE)" -t "$(IMAGE)" "$(CONTEXT)"

lint:
	BUILD=false RUN_GRYPE=false scripts/cve-scan.sh lint

scan:
	IMAGE="$(IMAGE)" DOCKERFILE="$(DOCKERFILE)" CONTEXT="$(CONTEXT)" REPORT_DIR="$(REPORT_DIR)" SEVERITY="$(SEVERITY)" IGNORE_UNFIXED="$(IGNORE_UNFIXED)" RUN_GRYPE="$(RUN_GRYPE)" BUILD="$(BUILD)" scripts/cve-scan.sh scan

scan-trivy:
	BUILD=false RUN_GRYPE=false IMAGE="$(IMAGE)" DOCKERFILE="$(DOCKERFILE)" REPORT_DIR="$(REPORT_DIR)" SEVERITY="$(SEVERITY)" IGNORE_UNFIXED="$(IGNORE_UNFIXED)" scripts/cve-scan.sh trivy

sbom:
	BUILD=false IMAGE="$(IMAGE)" REPORT_DIR="$(REPORT_DIR)" scripts/cve-scan.sh sbom

scan-grype:
	BUILD=false IMAGE="$(IMAGE)" REPORT_DIR="$(REPORT_DIR)" scripts/cve-scan.sh grype

clean-reports:
	rm -rf "$(REPORT_DIR)"/*
