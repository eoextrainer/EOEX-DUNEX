# Developer Workflow

This page explains the normal day-to-day developer flow in EOEX-DUNEX.

## Objective

Developers should not manage release branching or deployment targets manually. Their primary job is to implement a user story in a scratch org and retrieve the resulting metadata back into source control.

## Standard Path

1. Make sure the repository is initialized with `scripts/init-repo.sh`.
2. Make sure target orgs are authenticated with `scripts/setup-target-orgs.sh`.
3. Make sure monthly scratch orgs exist with `scripts/provision-monthly-scratch-orgs.sh`.
4. Create the user story folder under `manifest/user-stories/US-XXX/`.
5. Add `story.txt`.
6. Optionally add `metadata-hints.txt`.
7. Start the story with `scripts/start-user-story.sh`.
8. Implement and test in the assigned scratch org.
9. Run `scripts/retrieve-user-story.sh`.
10. Let the automation promote the story to `release`.

## Story Start Command

Example:

```bash
bash scripts/start-user-story.sh US-123 feat darnell
```

What it does:

- validates story parameters
- syncs local `main`
- refreshes `feat` or `fix` from `main`
- creates or refreshes the story branch
- generates the story `package.xml`
- opens the correct monthly scratch org

## Implementation Expectations

Developers are expected to:

- work only in the scratch org associated with their developer key
- keep changes aligned to the story scope
- validate behavior before retrieve
- avoid direct development on `main`, `dev`, `feat`, `fix`, `release`, `archive`, or `scratch`

## Retrieve Command

Example:

```bash
bash scripts/retrieve-user-story.sh US-123 feat darnell
```

What it does:

- checks out the story branch
- retrieves the story manifest from the scratch org
- creates a commit on the story branch
- archives the story as a tarball and patch on the `archive` branch
- merges upward into `feat` or `fix`, then `dev`, then `release`
- pushes `release` to `origin/release`

## Developer Responsibilities

- write accurate story text
- include metadata hints when story text is not enough to infer metadata
- test before retrieve
- resolve conflicts before rerunning automation
- keep local auth valid for the assigned scratch org

## Developer Non-Responsibilities

The workflow aims to remove these responsibilities from day-to-day developers:

- manually building release bundles
- manually deciding release branch promotion order
- deploying directly to shared integration or production targets