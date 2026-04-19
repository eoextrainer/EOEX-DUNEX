# Release History

This page is the wiki-facing release ledger for EOEX-DUNEX. It is seeded from the repository release notes structure and is intended to be updated whenever a release bundle moves through the downstream environments.

## Purpose

Use this page to track:

- what was included in a release bundle
- who coordinated the release
- which target environments received the bundle
- validation outcomes and known risks

## Recommended Operating Model

1. Build the release bundle from `release`.
2. Create or update detailed release notes under `docs/releases/<bundle-id>.md` in the repository.
3. Add a concise summary entry to this wiki page.
4. Update status as the bundle moves through `int`, `uat`, `prod`, and `main`.

## Release Index

| Bundle ID | Scope | Source Branch | Status | Notes |
| --- | --- | --- | --- | --- |
| US-CRM-001-baseline | Initial DUNEX CRM scaffold | release | Released to `origin/release` | First four-division CRM baseline with apps, objects, layouts, record pages, and app home pages |

## Current Release Record

### US-CRM-001-baseline

#### Scope

- Sprint / Epic / Train: Initial CRM baseline
- Source branch: `feat-US-CRM-001` promoted into `release`
- Target branch: `origin/release`
- Release manager: EOEX workflow automation / manual validation
- Deployment date: 2026-04-19

#### Included User Stories

- `US-CRM-001`: DUNEX Multi-Division CRM Scaffold

#### Developer Contributions

- Developer: repository automation flow from story branch
- Story: `US-CRM-001`
- Metadata delivered: applications, custom objects, custom fields, tabs, layouts, FlexiPages, permission set, workflow scripts, and supporting project documentation
- Validation performed: scratch-org deployment, record page verification, manual app home activation, English session verification

#### Merge Notes

- Conflicts encountered: none during automated story promotion to `release`
- Resolutions applied: not applicable
- Risks accepted: app home activation remains manual in-org; app-home activation metadata does not round-trip usefully into source

#### Bugs And Technical Caveats

- Reported: scratch org shows inconsistent custom-field visibility between Tooling metadata and normal data API/Apex compile paths
- Assigned: open technical investigation
- Implemented: workaround limited to base sample-record creation and manual UI validation
- Deferred: richer automated linked sample-data generation

#### Deployment Notes

- Push result: `release` pushed to `origin/release`
- Org deployed: `dunex-scratch-1` for validation
- Test level: metadata deployment validation and manual UAT checks
- Rollback plan: revert release commit or redeploy previous known-good release state

#### Environment Progression

| Stage | Branch / Org | Status | Validated By | Date | Notes |
| --- | --- | --- | --- | --- | --- |
| Release | `origin/release` | Complete | EOEX workflow automation | 2026-04-19 | Story promoted and release baseline published |
| INT | `int` / `int-org` | Pending |  |  |  |
| UAT | `uat` / `uat-org` | Pending |  |  |  |
| PROD | `prod` / `prod-org` | Pending |  |  |  |
| MAIN | `main` | Pending |  |  |  |

## Release Entry Template

Use this structure for future releases. It mirrors the repository template in `docs/release-notes-template.md`.

```md
### <BUNDLE-ID>

#### Scope

- Sprint / Epic / Train:
- Source branch:
- Target branch:
- Release manager:
- Deployment date:

#### Included User Stories

- US-XXX:
- US-YYY:

#### Developer Contributions

- Developer:
- Story:
- Metadata delivered:
- Validation performed:

#### Merge Notes

- Conflicts encountered:
- Resolutions applied:
- Risks accepted:

#### Bugs

- Reported:
- Assigned:
- Implemented:
- Deferred:

#### Deployment Notes

- Push result:
- Org deployed:
- Test level:
- Rollback plan:

#### Environment Progression

| Stage | Branch / Org | Status | Validated By | Date | Notes |
| --- | --- | --- | --- | --- | --- |
| Release | `origin/release` | Pending |  |  |  |
| INT | `int` / `int-org` | Pending |  |  |  |
| UAT | `uat` / `uat-org` | Pending |  |  |  |
| PROD | `prod` / `prod-org` | Pending |  |  |  |
| MAIN | `main` | Pending |  |  |  |
```