# Scripts Reference

This page is the quick reference for all major repository scripts.

## Foundation

### `scripts/common.sh`

Shared helpers used by most scripts.

Provides:

- command validation
- repo-root validation
- branch existence checks
- branch synchronization helpers
- developer lookup helpers
- scratch alias and username generation
- registry management
- temporary worktree helpers
- metadata reference conversion from file paths

## Setup And Initialization

### `scripts/init-repo.sh`

Purpose:

- initialize and synchronize the local branch model

### `scripts/setup-target-orgs.sh`

Purpose:

- authenticate shared target org aliases for `int`, `uat`, `prod`, and `dev-sandbox`

Special behavior:

- converts Trailblazer Lightning URLs to My Domain URLs when needed

## Story Workflow

### `scripts/start-user-story.sh`

Purpose:

- prepare a story branch and generate the story package manifest

Usage:

```bash
bash scripts/start-user-story.sh US-XXX feat|fix developer-key
```

### `scripts/generate-package.sh`

Purpose:

- infer story metadata scope from story text, hints, and dependencies

Usage:

```bash
bash scripts/generate-package.sh US-XXX
```

### `scripts/retrieve-user-story.sh`

Purpose:

- retrieve story-scoped metadata from the scratch org, commit it, archive it, and promote it to `release`

Usage:

```bash
bash scripts/retrieve-user-story.sh US-XXX feat|fix developer-key
```

### `scripts/promote-user-story.sh`

Purpose:

- merge a completed story branch into `feat` or `fix`, then `dev`, then `release`

## Scratch Org Lifecycle

### `scripts/provision-monthly-scratch-orgs.sh`

Purpose:

- create and provision monthly scratch orgs for all configured developers

### `scripts/archive-scratch-backup.sh`

Purpose:

- retrieve metadata and export configured data from scratch orgs into the `scratch` branch

## Release Flow

### `scripts/create-release-bundle.sh`

Purpose:

- create a bundle branch from selected commits on `release`

Usage:

```bash
bash scripts/create-release-bundle.sh BUNDLE-ID <commit> [commit...]
```

### `scripts/release-manager.sh`

Purpose:

- push and deploy the current `release` state into downstream branches and orgs

## Documentation And Wiki

### `scripts/import-github-wiki.sh`

Purpose:

- clone the repository GitHub Wiki
- mirror the local `wiki/` folder into the wiki repository
- commit and push the wiki update when content changes

Usage:

```bash
bash scripts/import-github-wiki.sh
```

### `scripts/refresh-wikio-branch.sh`

Purpose:

- create or refresh the dedicated local wiki clone in `tmp/wikio-branch`
- keep a local `wikio` branch aligned with the GitHub Wiki remote
- mirror the repository `wiki/` folder into that clone
- commit and push the updated wiki from the local `wikio` branch

Usage:

```bash
bash scripts/refresh-wikio-branch.sh
```

Useful options:

```bash
bash scripts/refresh-wikio-branch.sh --status
bash scripts/refresh-wikio-branch.sh --status --json
bash scripts/refresh-wikio-branch.sh --no-push
bash scripts/refresh-wikio-branch.sh --pull-only
bash scripts/refresh-wikio-branch.sh --sync-only
bash scripts/refresh-wikio-branch.sh --commit-message "docs(wiki): refresh local wikio branch"
```

## Suggested Usage Order

1. `init-repo.sh`
2. `setup-target-orgs.sh`
3. `provision-monthly-scratch-orgs.sh`
4. `start-user-story.sh`
5. implement and test
6. `retrieve-user-story.sh`
7. `release-manager.sh`