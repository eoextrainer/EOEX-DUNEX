# Developer and Technical Guide

This page is the technical overview for developers, admins, and maintainers.

## Who This Is For

This page is intended for:

- Salesforce developers
- release managers
- DevOps and platform maintainers
- technical admins

## Core Technical Model

The repository uses:

- Salesforce DX source format under `force-app`
- story-based packaging under `manifest/user-stories`
- bash automation under `scripts/`
- a branch model centered on `main`, `dev`, `feat`, `fix`, `archive`, `release`, and `scratch`

## Key Technical Responsibilities

- maintain source metadata in `force-app`
- keep story packaging reproducible
- manage scratch-org lifecycle through automation
- promote story work through the controlled branch model
- release only from `release`

## Technical Starting Points

- [[Repository Structure]]
- [[Configuration]]
- [[Developer Workflow]]
- [[User Story Lifecycle]]
- [[Scratch Orgs and Backups]]
- [[Release Management]]
- [[Scripts Reference]]

## Workflow Summary

1. initialize local branches
2. authenticate shared org aliases
3. provision monthly scratch orgs
4. start a story branch
5. implement in scratch org
6. retrieve and archive metadata
7. promote to `release`
8. deploy downstream with the release-manager flow

## Current Technical Caveats

- app-home activation is operational in the org but not reliably represented by meaningful retrieved source metadata
- custom-field visibility in the scratch org can differ between Tooling metadata and regular SOQL/Apex contexts
- backup completeness depends entirely on the maintained manifest and SOQL query set

## Technical Governance Rules

- do not work directly on protected coordination branches
- keep the working tree clean before running workflow scripts
- treat generated passwords and scratch registry files as sensitive local state
- keep configuration artifacts current when metadata or data coverage expands

## Recommended Maintenance Areas

- expand dependency mappings in `config/metadata-dependencies.csv`
- evolve story templates and hints as delivery patterns mature
- expand release-history tracking for downstream environments
- investigate scratch-org field visibility inconsistencies when sample-data automation matters