# Importing into GitHub Wiki

This page explains how to use the contents of the local `wiki/` folder as a GitHub Wiki.

## What Is Included

The `wiki/` folder is structured as a flat markdown page set compatible with GitHub Wiki conventions.

Included conventions:

- `Home.md` as the main landing page
- `_Sidebar.md` for left-hand wiki navigation
- page-to-page links using GitHub Wiki link syntax such as `[[Release Management]]`
- one page per topic, using markdown filenames that GitHub Wiki can translate into page names

## Recommended Import Method

GitHub Wikis are separate Git repositories. A typical import path is:

1. create or enable the GitHub Wiki for the repository
2. run the repository import script or clone the wiki repository locally
3. copy the contents of this repository's `wiki/` folder into the wiki repository root
4. commit and push the wiki repository

## Automated Import Script

The repository includes `scripts/import-github-wiki.sh` to perform the clone, sync, commit, and push flow safely.

Default usage:

```bash
bash scripts/import-github-wiki.sh
```

Useful options:

```bash
bash scripts/import-github-wiki.sh --no-push
bash scripts/import-github-wiki.sh --keep-clone
bash scripts/import-github-wiki.sh --commit-message "docs(wiki): refresh project wiki"
```

Behavior:

- derives the GitHub Wiki remote from the repository `origin`
- clones the wiki into a temporary directory under `tmp/`
- uses `rsync --delete` to mirror the local `wiki/` folder into the wiki repository
- creates a commit only when content actually changed
- pushes the update unless `--no-push` is supplied

## Example Process

```bash
bash scripts/import-github-wiki.sh
```

If you prefer the manual route, adjust the default branch name if the wiki repository uses a different branch.

## Important Notes

- keep page filenames stable after import so existing wiki links continue to work
- `_Sidebar.md` is recognized specially by GitHub Wiki
- `Home.md` is the default landing page
- the `wiki/` folder in the application repository is only the source set for import; GitHub will not automatically render it as the live wiki unless copied into the wiki repository

## Update Strategy

Recommended maintenance model:

1. update the source markdown pages in `wiki/` inside the main repository
2. review changes like any other documentation update
3. run `scripts/import-github-wiki.sh` or copy the updated pages into the GitHub Wiki repository manually
4. commit and push the wiki repository