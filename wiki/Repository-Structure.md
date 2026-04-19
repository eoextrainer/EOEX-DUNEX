# Repository Structure

This page describes the major folders and what each one is responsible for.

## Top-Level Layout

```text
README.md
sfdx-project.json
.github/
config/
docs/
force-app/
manifest/
scripts/
backups/
tmp/
wiki/
```

## Key Directories

### `force-app/`

The Salesforce DX source-format metadata root.

Important contents include:

- `applications/`
- `flexipages/`
- `layouts/`
- `objects/`
- `permissionsets/`
- `tabs/`

### `manifest/`

Contains deploy and retrieve manifests.

Key items:

- `manifest/package.xml`: the broad metadata scope used for backups and restore operations
- `manifest/user-stories/`: one folder per user story

### `manifest/user-stories/`

Each story folder follows this pattern:

```text
manifest/user-stories/US-XXX/
  story.txt
  metadata-hints.txt
  package.xml
  metadata-analysis.txt
```

Purpose of each file:

- `story.txt`: required business story text
- `metadata-hints.txt`: optional explicit metadata additions
- `package.xml`: generated metadata manifest for the story
- `metadata-analysis.txt`: generated analysis of selected metadata

### `scripts/`

Contains the workflow automation layer.

Main scripts include:

- `init-repo.sh`
- `setup-target-orgs.sh`
- `provision-monthly-scratch-orgs.sh`
- `start-user-story.sh`
- `generate-package.sh`
- `retrieve-user-story.sh`
- `promote-user-story.sh`
- `archive-scratch-backup.sh`
- `create-release-bundle.sh`
- `release-manager.sh`

### `config/`

Contains workflow inputs and shared configuration.

Key files:

- `developers.csv`
- `project-scratch-def.json`
- `metadata-dependencies.csv`
- `data-export-queries/*.soql`

### `docs/`

Contains operational documentation and release notes templates.

Current core documentation:

- `release-management-guide.md`
- `release-notes-template.md`

### `.github/workflows/`

Contains GitHub Actions automation.

Current workflow:

- `release-bundle.yml`

### `backups/`

Used by the scratch backup workflow. The `scratch` branch stores archived metadata and exported data under this area.

### `tmp/`

Temporary working files used by scripts and ad hoc operations. This directory should not be treated as source of truth.

### `wiki/`

The import-ready GitHub Wiki content set contained in markdown pages.

## Source of Truth Rules

- deployable metadata lives in `force-app/`
- backup scope is controlled by `manifest/package.xml`
- story-specific scope is controlled by generated manifests under `manifest/user-stories/`
- operational behavior is defined by the scripts under `scripts/`