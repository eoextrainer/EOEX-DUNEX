# EOEX-DUNEX

Salesforce DX bootstrap for the DUNEX CRM release-management workflow.

The repository now includes:

- a Salesforce DX project scaffold
- a documented branch and release strategy
- local bash automation for scratch-org lifecycle and user-story promotion
- GitHub Actions support for release bundles

Start here:

1. Read [docs/release-management-guide.md](docs/release-management-guide.md).
2. Run `scripts/init-repo.sh` to create and sync the local branch model.
3. Run `scripts/setup-target-orgs.sh` to authenticate the shared deployment orgs.
4. Set `DEVHUB_ALIAS` in your shell and run `scripts/provision-monthly-scratch-orgs.sh`.

Important Salesforce constraints:

- Scratch-org admin passwords cannot be forced to a fixed shared value with Salesforce CLI; the script generates and records random passwords locally.
- Scratch-org admin usernames must be globally unique; the script uses deterministic monthly usernames derived from each developer name.
- A literal full-org data backup is not realistic with standard CLI alone; the workflow exports the metadata scope in `manifest/package.xml` and the configured SOQL datasets in `config/data-export-queries/`.