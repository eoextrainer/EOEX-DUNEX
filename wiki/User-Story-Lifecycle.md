# User Story Lifecycle

This page explains how stories are represented and how metadata scope is derived.

## Story Folder Format

Every story lives under:

```text
manifest/user-stories/US-XXX/
```

Minimum required file:

- `story.txt`

Optional file:

- `metadata-hints.txt`

Generated files:

- `package.xml`
- `metadata-analysis.txt`

## How Package Generation Works

`scripts/generate-package.sh` builds the story manifest by:

1. reading `story.txt`
2. scanning metadata files under `force-app/main/default`
3. converting file paths into metadata references
4. selecting members whose names appear in the story text
5. adding explicit members from `metadata-hints.txt`
6. expanding dependencies using `config/metadata-dependencies.csv`
7. writing `package.xml`
8. writing `metadata-analysis.txt`

## Why `metadata-hints.txt` Exists

Story text often does not mention every deployable member precisely enough. Use hints when:

- a member name would not naturally appear in business-facing text
- a dependency is project-specific and not already in `metadata-dependencies.csv`
- the selected scope needs to be explicit for review

## Example Hint Format

```text
CustomObject:Studio_Project__c
CustomField:Studio_Project__c.Client__c
FlexiPage:Studio_Project_Record_Page
```

## Archive Behavior

When a story is retrieved:

- the story branch diff is patched and archived
- a tarball of the branch is created
- story text and analysis are copied into the archive snapshot
- the archive is committed onto the `archive` branch

## Promotion Chain

Normal promotion path:

```text
story branch -> feat/fix -> dev -> release -> origin/release
```

## Current Example Story

`US-CRM-001` is the current reference implementation in this repository. It introduced the first DUNEX multi-division CRM scaffold, including:

- four Lightning apps
- eight custom objects
- tabs, layouts, and Lightning pages
- a shared permission set for access

See [[CRM Scaffold]] for the functional summary.