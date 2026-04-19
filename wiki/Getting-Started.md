# Getting Started

This page explains how to get a working EOEX-DUNEX local environment from a fresh clone.

## Prerequisites

Install and verify these tools before using the repository:

- `git`
- Salesforce CLI `sf`
- a Salesforce Dev Hub alias available locally
- shell access that can run the repository bash scripts

## Initial Setup

1. Clone the repository.
2. Change into the repository root.
3. Run:

```bash
bash scripts/init-repo.sh
```

This script:

- fetches from `origin`
- syncs local `main`
- ensures `dev`, `feat`, `fix`, `archive`, `scratch`, and `release` exist locally
- aligns `release` with `origin/release` when the remote branch exists

## Authenticate Shared Target Orgs

Run:

```bash
bash scripts/setup-target-orgs.sh
```

This script authenticates these aliases:

- `int-org`
- `uat-org`
- `prod-org`
- `dev-sandbox-org`

Important behavior:

- the script accepts Trailblazer Lightning URLs and converts them to My Domain URLs when needed
- the actual login still requires a human browser session
- Salesforce CLI rejects some Lightning-domain URLs directly, so the script normalizes them

## Provision Monthly Scratch Orgs

Set your Dev Hub alias first:

```bash
export DEVHUB_ALIAS=<your-devhub-alias>
```

Then run:

```bash
bash scripts/provision-monthly-scratch-orgs.sh
```

This creates one monthly scratch org per developer from `config/developers.csv`.

## Sensitive Local Files

These outputs are intentionally local and should not be committed:

- `config/generated-passwords/`
- `config/scratch-org-registry.csv`
- Salesforce auth state under `.sf/` and `.sfdx/`

## Recommended First Reads

- [[Repository Structure]]
- [[Configuration]]
- [[Developer Workflow]]
- [[Release Management]]