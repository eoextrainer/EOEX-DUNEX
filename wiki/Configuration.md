# Configuration

This page explains the main configuration files that drive the project.

## `sfdx-project.json`

Defines the Salesforce DX project configuration.

Current behavior:

- default package directory: `force-app`
- package name: `EOEX-DUNEX`
- namespace: empty
- login URL: `https://login.salesforce.com`
- source API version: `62.0`

## `config/project-scratch-def.json`

Defines the scratch-org shape used by the monthly provisioning script.

Current settings include:

- `Enterprise` edition
- default language `en_US`
- features:
  - `API`
  - `AuthorApex`
  - `ContactsToMultipleAccounts`
  - `LightningSalesConsole`
  - `PersonAccounts`
- Lightning Experience enabled

## `config/developers.csv`

Defines the list of developers for monthly scratch provisioning.

Columns:

- `key`
- `name`
- `email`
- `base_username`

This file is used to:

- generate scratch aliases
- generate globally unique monthly usernames
- assign admin email during org creation

## `config/metadata-dependencies.csv`

Defines extra dependency edges used by `scripts/generate-package.sh`.

Format:

```text
source,target
MetadataType:Member,MetadataType:Member
```

If a source member is selected for a story, the target member is added automatically.

## `config/data-export-queries/`

Contains SOQL files used by the backup automation.

Current example:

- `accounts.soql`

These queries define which data sets are exported during scratch backups.

## Generated Local Configuration

These files are created locally by scripts and should be treated as operational state, not committed metadata:

- `config/generated-passwords/<alias>.txt`
- `config/scratch-org-registry.csv`

## Shared Org Aliases

The project expects these aliases to be authenticated locally:

- `int-org`
- `uat-org`
- `prod-org`
- `dev-sandbox-org`

These are set up by `scripts/setup-target-orgs.sh`.

## Configuration Practices

- keep `manifest/package.xml` current because scratch backup and restore depend on it
- keep `config/data-export-queries/` current because backup data continuity depends on it
- keep `config/metadata-dependencies.csv` current when metadata selection by story text is not sufficient