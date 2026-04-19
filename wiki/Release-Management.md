# Release Management

This page explains how EOEX-DUNEX moves work beyond `release`.

## Release Philosophy

Developers promote completed story work to `origin/release`. Release management then proceeds from `release` into downstream targets.

The release manager does not work from scratch orgs.

## Branch Model

Core branches:

- `main`
- `dev`
- `feat`
- `fix`
- `archive`
- `release`
- `scratch`

Story branches:

- `feat-US-XXX`
- `fix-US-XXX`

## Story Promotion To Release

`scripts/promote-user-story.sh` performs this path:

```text
story branch -> feat or fix -> dev -> release -> origin/release
```

It merges with `--no-ff` and then pushes `origin/release`.

## Release Bundle Workflow

For sprint or train aggregation, the project also supports bundle creation.

Options:

- local script: `scripts/create-release-bundle.sh`
- GitHub Action: `.github/workflows/release-bundle.yml`

Both approaches:

- pull the latest `release`
- create a `bundle/<bundle-id>` branch
- cherry-pick selected commits with `--no-commit`
- create a single release bundle commit

## Release Manager Console

The main downstream promotion tool is:

```bash
bash scripts/release-manager.sh
```

Menu actions:

1. Push to `int`
2. Deploy to `int-org`
3. Push to `uat`
4. Deploy to `uat-org`
5. Push to `prod`
6. Deploy to `prod-org`
7. Push to `main`
8. Exit

## Exact Operational Sequence

Typical sequence after release approval:

1. check out `release`
2. pull `origin/release`
3. push the current `release` HEAD to `origin/int`
4. deploy `force-app` to `int-org`
5. validate integration
6. push to `origin/uat`
7. deploy to `uat-org`
8. validate UAT
9. push to `origin/prod`
10. deploy to `prod-org`
11. validate production
12. push the same state to `origin/main`

## Shared Target Aliases

The release flow expects these aliases to exist locally:

- `int-org`
- `uat-org`
- `prod-org`

These are authenticated by `scripts/setup-target-orgs.sh`.

## Release Guardrails

- do not run release promotion from a dirty working tree
- sync `release` from `origin/release` before downstream promotion
- resolve merge conflicts before rerunning any automation
- use validation gates between `int`, `uat`, and `prod`