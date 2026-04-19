# Scratch Orgs and Backups

This page explains the monthly scratch-org model and the backup process.

## Monthly Scratch Org Strategy

The repository provisions one monthly scratch org per developer. The provisioning command is:

```bash
bash scripts/provision-monthly-scratch-orgs.sh
```

Required environment variable:

```bash
export DEVHUB_ALIAS=<your-devhub-alias>
```

## Alias and Username Format

Scratch aliases are deterministic and monthly:

```text
dunex-<developer-key>-YYYY-MM
```

Scratch usernames are also deterministic and monthly:

```text
<base_username>.YYYYMM@dunex.scratch
```

This is necessary because Salesforce requires globally unique usernames.

## What Provisioning Does

For each developer in `config/developers.csv`, the script:

1. syncs local `main`
2. creates a 30-day scratch org
3. deploys the current `force-app`
4. restores the latest scratch backup if available
5. generates a password
6. records state in `config/scratch-org-registry.csv`

## Password Handling

Scratch admin passwords are generated randomly and stored locally under:

```text
config/generated-passwords/
```

These files are sensitive and must not be committed.

## Backup Strategy

Scratch backups are handled by:

```bash
bash scripts/archive-scratch-backup.sh all
```

You can also target a single developer key.

## What Backup Captures

The backup script:

1. retrieves the metadata defined in `manifest/package.xml`
2. exports data defined by `config/data-export-queries/*.soql`
3. writes the result under the `scratch` branch
4. refreshes a `latest` pointer per developer

## Backup Storage Layout

Stored on the `scratch` branch under:

```text
backups/scratch/<developer>/<YYYY-MM>/
backups/scratch/<developer>/latest/
```

## Important Limitation

This is not a full sandbox-grade backup system.

The backup is only as complete as:

- the metadata in `manifest/package.xml`
- the SOQL datasets under `config/data-export-queries/`

If broader data retention is required, a dedicated backup solution is still needed.