# EOEX-DUNEX Wiki

This wiki is the import-ready knowledge base for the EOEX-DUNEX Salesforce DX project. It documents the repository structure, branch model, developer workflow, scratch-org lifecycle, release process, configuration files, automation scripts, and the current DUNEX CRM scaffold.

## Project Summary

EOEX-DUNEX is a Salesforce DX repository used to manage:

- Salesforce metadata in source format under `force-app`
- story-based delivery under `manifest/user-stories`
- monthly scratch-org provisioning and backup automation
- release promotion from local story work to `release`
- downstream promotion from `release` to `int`, `uat`, `prod`, and `main`

The repository is designed so developers work from story branches and scratch orgs, while release management happens from `release`.

## Read This First

- [[Getting Started]]
- [[Repository Structure]]
- [[Configuration]]
- [[Business-User-Guide]]
- [[Developer-and-Technical-Guide]]
- [[Developer Workflow]]
- [[User Story Lifecycle]]
- [[Scratch Orgs and Backups]]
- [[Release Management]]
- [[Release History]]
- [[CRM Scaffold]]
- [[Scripts Reference]]
- [[Troubleshooting]]
- [[Importing into GitHub Wiki]]

## Audience Paths

### Business Users And Stakeholders

- [[Business-User-Guide]]
- [[CRM Scaffold]]
- [[Release History]]

### Developers And Technical Maintainers

- [[Developer-and-Technical-Guide]]
- [[Developer Workflow]]
- [[User Story Lifecycle]]
- [[Scratch Orgs and Backups]]
- [[Release Management]]
- [[Scripts Reference]]
- [[Troubleshooting]]

## PR Templates

The repository now includes two pull request templates so contributors can pick the right structure for the type of change being proposed.

- general work: `.github/PULL_REQUEST_TEMPLATE/default.md`
- wiki and wiki-publishing work: `.github/PULL_REQUEST_TEMPLATE/wiki.md`

## Core Workflow At A Glance

1. Clone the repository.
2. Run `scripts/init-repo.sh` to establish the local branch model.
3. Run `scripts/setup-target-orgs.sh` to authenticate shared org aliases.
4. Set `DEVHUB_ALIAS` and run `scripts/provision-monthly-scratch-orgs.sh`.
5. Create `manifest/user-stories/US-XXX/story.txt`.
6. Run `scripts/start-user-story.sh US-XXX feat|fix developer-key`.
7. Build and test in the developer scratch org.
8. Run `scripts/retrieve-user-story.sh US-XXX feat|fix developer-key`.
9. Let the automation archive the work and promote it to `release`.
10. Use `scripts/release-manager.sh` to move from `release` into `int`, `uat`, `prod`, and `main`.

## Design Principles

- Story-first delivery: every meaningful change should trace back to a user story folder.
- Source-controlled metadata: the repository is the source of truth for deployable metadata.
- Automated promotion: developer changes should move through the branch model predictably.
- Reproducible packaging: story manifests are generated from story text and explicit hints.
- Controlled release flow: production promotion happens from `release`, not from feature branches or scratch orgs.

## Current Functional Scope

The current project includes the first DUNEX CRM scaffold for four business divisions:

- DUNEX Studio
- DUNEX Academy
- DUNEX Events
- DUNEX Publishing Kiosk

That scaffold includes custom applications, custom objects, tabs, layouts, Lightning record pages, app home pages, and the `DUNEX_CRM_Access` permission set.