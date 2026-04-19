# DUNEX Release Management Workflow

## 1. Objective

This workflow standardises how the DUNEX Salesforce team pulls from GitHub, provisions monthly scratch orgs, implements user stories, retrieves metadata back into Git, archives monthly backups, promotes changes to release, and assembles sprint release bundles.

The target outcome is that developers do not manually manage Git branching, scratch-org creation, or upstream promotion. Their job is limited to:

1. read the assigned user story
2. save the user story text under `manifest/user-stories/US-XXX/story.txt`
3. log into the assigned scratch org
4. implement and test the story in Salesforce
5. run the retrieval script when ready

## 2. Branch Strategy

The local branch model is:

```text
main
dev
feat
fix
archive
release
scratch
feat-US-XXX
fix-US-XXX
```

Practical note: Git stores branches as a flat namespace, so the parent-child hierarchy is procedural rather than literal. `feat-US-XXX` is created from `feat`, `fix-US-XXX` is created from `fix`, `feat` and `fix` are refreshed from `main`, `dev` aggregates them, and `release` is the branch pushed upstream.

Branch responsibilities:

- `main`: local tracking copy of `origin/main`
- `dev`: integration branch for local feature and bug-fix work
- `feat`: parent branch for feature stories
- `fix`: parent branch for bug-fix stories
- `archive`: immutable history of user-story archive bundles and patches
- `release`: local branch aligned to `origin/release`
- `scratch`: history branch for monthly scratch-org metadata and data backups

## 3. End-to-End Developer Flow

### Repository preparation

1. Clone `git@github.com:eoextrainer/EOEX-DUNEX.git`.
2. Run `scripts/init-repo.sh`.
3. Authenticate the deployment orgs with `scripts/setup-target-orgs.sh`.
4. Export `DEVHUB_ALIAS=<your-devhub-alias>`.
5. Run `scripts/provision-monthly-scratch-orgs.sh` at the start of each month.

### User-story execution

1. Create `manifest/user-stories/US-XXX/story.txt`.
2. Optionally add `metadata-hints.txt` for components that cannot be inferred from the text.
3. Run `scripts/start-user-story.sh US-XXX feat darnell` or `scripts/start-user-story.sh US-XXX fix julian`.
4. The script pulls `origin/main`, refreshes the parent `feat` or `fix` branch from `main`, checks out `feat-US-XXX` or `fix-US-XXX`, generates `package.xml`, and opens the developer scratch org.
5. The developer implements the story in the scratch org.
6. Run `scripts/retrieve-user-story.sh US-XXX feat darnell` or the `fix` equivalent.
7. The script retrieves the generated `package.xml` scope from the scratch org, creates the story commit on the story branch, archives a tarball and patch on `archive`, merges upward into the parent branch, then into `dev`, then into `release`, and pushes `release` to `origin/release`.

### Promotion chain

```text
feat-US-XXX or fix-US-XXX
  -> commit on story branch
  -> archive bundle committed on archive
  -> merge into feat or fix
  -> merge into dev
  -> merge into release
  -> push origin/release
```

## 4. Monthly Scratch-Org Lifecycle

### Provisioning

At the start of each month, `scripts/provision-monthly-scratch-orgs.sh`:

1. syncs local `main` from `origin/main`
2. creates a 30-day scratch org per developer
3. assigns a deterministic monthly alias such as `dunex-darnell-2026-04`
4. uses a unique monthly username derived from the developer name
5. deploys the latest local `main` source into the new scratch org
6. restores the latest metadata and configured data backup from the `scratch` branch if one exists
7. generates a random password and saves it to `config/generated-passwords/<alias>.txt`
8. writes the active org registry to `config/scratch-org-registry.csv`

### Backup

One day before month end, `scripts/archive-scratch-backup.sh all`:

1. retrieves the metadata scope defined in `manifest/package.xml`
2. exports the configured SOQL datasets in `config/data-export-queries/`
3. commits the backup into the `scratch` branch under `backups/scratch/<developer>/<YYYY-MM>/`
4. refreshes `backups/scratch/<developer>/latest/`

Important limitation: CLI-based backup is only as complete as the metadata manifest and SOQL export definitions you maintain. If you need full sandbox-grade data preservation, use a dedicated backup product or Salesforce Data Export in addition to this workflow.

## 5. User-Story Metadata Analysis

The story preparation script reads `story.txt` and:

1. scans local Salesforce source under `force-app/main/default`
2. matches metadata names that appear in the story text
3. loads explicit additions from `metadata-hints.txt`
4. expands dependencies from `config/metadata-dependencies.csv`
5. writes `manifest/user-stories/US-XXX/package.xml`
6. writes `manifest/user-stories/US-XXX/metadata-analysis.txt`

This gives the team a reproducible `package.xml` that can be reviewed before retrieve.

## 6. Release Manager Flow

The release manager does not work from developer scratch orgs. Instead, they operate from `origin/release`.

The release-bundle process is:

1. pull the latest `origin/release`
2. select the story commits required for the sprint, epic, or release train
3. cherry-pick those commits into a bundle branch with `--no-commit`
4. squash them into one release commit
5. generate `docs/releases/<bundle-id>.md`
6. push the bundle to `origin/int`
7. deploy to the integration org
8. repeat for `uat`, `prod`, and then `main` when approved

The local console for this is `scripts/release-manager.sh`.

Menu options:

- push to `int`
- deploy to the `int` org
- push to `uat`
- deploy to the `uat` org
- push to `prod`
- deploy to the `prod` org
- push to `main`

## 7. Shared Environment Aliases

Authenticate these orgs once with `scripts/setup-target-orgs.sh`:

- `int-org`: `https://brave-goat-8vbdse-dev-ed.my.salesforce.com`
- `uat-org`: `https://cunning-moose-9keyzh-dev-ed.my.salesforce.com`
- `prod-org`: `https://curious-bear-g70af2-dev-ed.my.salesforce.com`
- `dev-sandbox-org`: `https://creative-raccoon-cqx65l-dev-ed.my.salesforce.com`

The script opens Salesforce web login for each target; the actual auth still requires a human browser login because Salesforce CLI cannot securely pre-seed those credentials from source control. If you start from a Lightning URL, convert it to the org's My Domain form because `sf org login web` rejects Lightning-domain instance URLs.

## 8. Operational Guardrails

- Never develop directly on `main`, `dev`, `feat`, `fix`, `release`, `archive`, or `scratch`.
- Resolve merge conflicts before re-running the automation; the scripts abort on conflicts.
- Keep `manifest/package.xml` current, because monthly backup and restore use it.
- Keep `config/data-export-queries/` current, because data continuity depends on those files.
- Treat `config/generated-passwords/` as sensitive local output; do not commit it.
