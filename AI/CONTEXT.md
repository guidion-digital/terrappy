---
repo: guidion-digital/terrappy
project_name: terrappy
owner: Cinfra
domain: Terraform and CI/CD automation
criticality: UNSET
summary: Describes the Terraform framework used at Guidion and provides documentation and shell automation for preparing Terraform backends and related CI/CD workflows.
main_stack:
  - Shell
  - Markdown
  - Terraform tooling
main_systems:
  - Terraform backend preparation script
  - CI/CD and permissions documentation
last_reviewed: 2026-09-02
review_confidence: low
generated_by: OpenAI
validated_by: Afraz
---

## Overview

Describes the Terraform framework called "Terrappy", used by Guidion. Contains documentation and a shell scripts for preparing a Terraform backend for use with Terrappy. The available repository structure does not include application source code or Terraform configuration files.

## Purpose and responsibilities

- Document CI/CD usage, contribution guidance, permissions, and preparation procedures.
- Provide `prepare_terraform_backend.sh` for Terraform backend preparation.
- Explain preparation-script behavior in `prepare-script.md`.

## Source of truth / data ownership

The repository owns its backend-preparation script and supporting documentation. Ownership of infrastructure state and external data cannot be determined from the available repository structure.

## External integrations

Terraform backend infrastructure is implied by `prepare_terraform_backend.sh`. Specific providers, platforms, and external systems are not identifiable from the available repository structure.

## APIs exposed

n/a — no exposed API or application service is evident from the repository structure.

## APIs / services consumed

Terraform tooling and a remote backend service are likely consumed by the preparation workflow, but the specific services are not identifiable from the available repository structure.

## Deployment

No deployable application is evident. Deployment and CI/CD guidance is documented in `cicd.md`; backend preparation is performed through `prepare_terraform_backend.sh`.

## Architectural notes and key decisions

- The repository is documentation- and script-oriented rather than an application codebase.
- Terraform backend preparation is encapsulated in a root-level shell script.
- Operational guidance is split across `README.md`, `cicd.md`, `permissions.md`, and `prepare-script.md`.

## Known risks / fragile areas

- Repository ownership and criticality are unset.
- Backend preparation scripts can affect shared infrastructure or state; review commands, credentials, permissions, and target environments before execution.
- Integration details cannot be validated from the directory structure alone.

## AI assistant guidance

- Read `README.md`, `prepare-script.md`, and `prepare_terraform_backend.sh` before changing backend preparation behavior.
- Consult `cicd.md` and `permissions.md` for workflow and access expectations.
- Preserve shell-script safety and avoid exposing credentials or backend secrets.
- Do not infer a specific Terraform provider or backend without confirming it from repository content.

## Roadmap / active migrations

n/a — no active roadmap or migration is evident from the provided git history or repository structure.

## Freshness

No commits were reported in the last 7 days. This context was generated from the current root-level repository structure; detailed repository contents were not provided, so review confidence is low.
- `last_reviewed`: 2026-09-02
- `generated_by`: CI-generated
