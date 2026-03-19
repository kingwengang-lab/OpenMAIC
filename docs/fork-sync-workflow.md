# Fork Sync Workflow

This repository is maintained as a fork with two remotes:

- `origin`: your own GitHub repository
- `upstream`: the official `THU-MAIC/OpenMAIC` repository

The goal is to keep `main` as a clean sync baseline and do custom work in feature branches.

## Branch Policy

- `main` is reserved for upstream syncs and must stay close to `upstream/main`
- Custom development happens on `feature/...` branches
- `release` is reserved for production-ready changes that are safe to deploy
- `main` is not the production deployment branch once custom work starts shipping

## Daily Workflow

1. Sync the official changes into your local `main`
2. Push the updated `main` to your fork
3. Merge the refreshed `main` into your active feature branch

Recommended command:

```bash
pnpm sync:upstream
```

Dry-run preview:

```bash
pnpm sync:upstream -- --dry-run
```

What the sync script does:

```bash
git fetch upstream
git checkout main
git merge --ff-only upstream/main
git push origin main
```

## Feature Development

Create new work from the current `main` baseline:

```bash
pnpm feature:new -- your-feature-name
```

Equivalent manual flow:

```bash
git checkout main
pnpm sync:upstream
git checkout -b feature/your-feature-name
```

Create and push immediately:

```bash
pnpm feature:new -- your-feature-name --push
```

After upstream syncs, bring the latest baseline into your active feature branch:

```bash
git checkout feature/your-feature-name
git merge main
```

The feature helper does four things in order:

1. Verifies you are in a clean working tree
2. Syncs `main` from `upstream/main`
3. Creates `feature/<topic>`
4. Optionally pushes the branch to `origin`

## Release Workflow

- `release` is the only branch that should back the Vercel production environment
- Only merge work into `release` after the corresponding `feature/...` branch passes local checks and Vercel preview validation
- Bring upstream changes into `release` by merging refreshed `main` into `release`
- Rollbacks happen on `release`, not on `main`

Create the release branch once:

```bash
git branch release main
git push -u origin release
```

Typical release update flow:

```bash
git checkout release
git merge main
git merge feature/your-feature-name
git push origin release
```

## Conflict Policy

- Upstream changes are resolved on `main` first
- Custom conflicts are resolved on feature or release branches
- Do not accumulate custom changes directly on `main`
- Do not force-push shared branches unless you explicitly intend to rewrite history

## GitHub and Vercel Settings

Apply these repository settings after the branch model is in place:

- GitHub branch protection for `main`
  - Block direct pushes
  - Require pull requests for non-sync changes
- GitHub branch protection for `release`
  - Block force pushes
  - Require review before production merges if collaborators are involved
- Vercel production branch
  - Set Production Branch to `release`
  - Let `feature/...` branches create Preview Deployments only
  - Keep `main` available as the upstream-sync baseline, not the live site branch

## Verification Checklist

- `git remote -v` shows both `origin` and `upstream`
- `git status -sb` is clean before syncing
- `git log --oneline --decorate --graph --all` shows `upstream/main` flowing into `main`
- Feature branches are created from the latest `main`
- `release` exists on both local and `origin`
- Vercel production is configured to deploy from `release`
