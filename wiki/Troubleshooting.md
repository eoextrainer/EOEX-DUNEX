# Troubleshooting

This page collects the main operational issues already observed in the project.

## Target Org Login Fails

Problem:

- `sf org login web` can fail when given a Lightning-domain URL directly.

Resolution:

- use the My Domain URL form instead
- or use `scripts/setup-target-orgs.sh`, which converts supported Trailblazer Lightning URLs automatically

## Scratch Backup Is Missing Data

Problem:

- backups do not include everything expected

Cause:

- backup scope only includes metadata from `manifest/package.xml`
- data export only includes the SOQL files under `config/data-export-queries/`

Resolution:

- update `manifest/package.xml`
- update or add SOQL export files

## Story Package Misses Metadata

Problem:

- generated story `package.xml` does not include all required members

Resolution:

- add explicit entries to `metadata-hints.txt`
- add reusable dependency mappings to `config/metadata-dependencies.csv`

## Shared Org Aliases Are Not Connected

Problem:

- release-manager deploys cannot run because `int-org`, `uat-org`, or `prod-org` are missing locally

Resolution:

- rerun `scripts/setup-target-orgs.sh`
- complete the web login interactively

## App Home Page Activation Does Not Round-Trip To Source

Observed behavior:

- app home pages can be activated manually in the org
- retrieval may not produce meaningful source metadata for the app-home assignment itself

Recommended handling:

- keep the `FlexiPage` definitions in source
- document activation as a manual in-org step when necessary

## Custom Field Visibility Mismatch In Scratch Org

Observed behavior:

- Tooling metadata can list custom fields on some custom objects
- the normal data API or Apex compile path can still reject those same field names in the scratch org session

Recommended handling:

- verify field availability with normal SOQL before scripting sample-data creation
- do not assume Tooling visibility alone is sufficient

## Merge Conflicts During Promotion

Problem:

- automation stops because target branches cannot be fast-forwarded or merged cleanly

Resolution:

- resolve conflicts manually first
- rerun the workflow only after the tree is clean and branch state is coherent

## Working Tree Is Dirty Before Running Scripts

Problem:

- script behavior becomes unsafe or misleading when local changes already exist

Resolution:

- commit, stash, or discard unrelated changes before rerunning automation