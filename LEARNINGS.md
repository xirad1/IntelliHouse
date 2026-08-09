# LEARNINGS.md

Log of conclusions and decisions from working on the IntelliHouse repository — append-only (don't
overwrite old entries, add new ones at the top). Each entry should answer: what happened, what the
problem was, what worked/didn't work, and what to remember for the future.

## Entry template

```
### YYYY-MM-DD — short title
- Context:
- Problem:
- Solution / decision:
- Takeaway:
```

---

### 2026-08-09 — PhotoPrism decommission completed
- Context: follow-up to the decision below to drop PhotoPrism in favor of Immich.
- Problem: `photoprism/` still existed in the repo and in `CLAUDE.md`'s host table after the owner
  removed the PhotoPrism containers/volumes directly on QNAP.
- Solution / decision: removed the `photoprism/` directory from the repo, removed it from the host table
  and secrets examples in `CLAUDE.md`, removed its row from the status table in `PLAN.md`, and moved the
  decommission checklist to "Done". Password rotation for the credentials that were in
  `photoprism/photoprism.yml` remains an open security backlog item, since those passwords are still in
  git history even after the file's removal.
- Takeaway: removing a file from the working tree does not remove secrets from git history — track
  credential rotation as a separate, explicit backlog item even after a service's files are deleted.

### 2026-08-09 — Decided to decommission PhotoPrism in favor of Immich
- Context: both PhotoPrism and Immich were running side by side on QNAP TS-364 as photo-management solutions.
- Problem: running two overlapping photo-management stacks is extra maintenance/security surface for no
  added benefit; the owner decided Immich currently is the better solution.
- Solution / decision: PhotoPrism marked as deprecated in `PLAN.md`, with a decommission checklist added
  (verify Immich covers PhotoPrism's photo libraries, back up `photoprism_db_data`, tear down containers/volumes
  on QNAP, then remove `photoprism/` from the repo and from the host table in `CLAUDE.md`). Not removing the
  directory or touching the running containers yet — that requires host-side action and confirmation.
- Takeaway: decommissioning a service is a multi-step process (data verification → backup → teardown →
  repo cleanup), not a single file deletion — track it as its own backlog item instead of doing it in one shot.

### 2026-08-09 — `git push` failed with `Permission denied (publickey)`
- Context: after committing new files (`CLAUDE.md`, `PLAN.md`, `.claude/`, `.github/agents/`), `git push`
  to `git@github.com:xirad1/IntelliHouse.git` failed.
- Problem: the local machine's `ssh-agent` had no loaded identities (`ssh-add -l` → "The agent has no
  identities"). After loading the only local key (`ssh-add ~/.ssh/id_rsa`), auth still failed because that
  key belonged to an unrelated (work) identity, not the `xirad1` GitHub account. The `xirad_github_id_rsa`
  key mentioned in `README.md` was set up for deploying to the QNAP server, not for pushing from this machine.
- Solution / decision: added the local machine's public key to GitHub → Settings → SSH and GPG keys for the
  `xirad1` account, then `ssh -T git@github.com` confirmed `Hi xirad1!` and `git push` succeeded.
- Takeaway: on a new machine, check `ssh-add -l` and `ssh -T git@github.com` *before* assuming a key
  works — a loaded key isn't necessarily the right one. Full steps now documented in `CLAUDE.md`
  ("Pushing to GitHub (SSH setup)"). Also: never paste SSH passphrases or GitHub 2FA/recovery codes into
  chat — during this troubleshooting a set of GitHub recovery codes was accidentally pasted into the AI
  chat and had to be treated as compromised and regenerated.

### 2026-08-09 — Started working with AI files (CLAUDE.md / PLAN.md / LEARNINGS.md)
- Context: the repo is growing (services: Immich, Nextcloud, PhotoPrism, WordPress, XWiki), with plans
  for Home Assistant (Raspberry Pi) and nginx (BananaPi), directories not yet created.
- Problem: no standardized place for AI context (conventions, host map) or for tracking the plan/learnings.
- Solution / decision: introduced three meta files at the repo root, the "one directory per service,
  `<service>.yml` file" convention is described in `CLAUDE.md`.
- Takeaway: don't design solutions for a specific hardware model (QNAP) — keep patterns general, since
  the infrastructure is spread across several different hosts.

### 2026-08-09 — Found plaintext secrets in compose files
- Context: review of `nextcloud/nextcloud.yml`, `photoprism/photoprism.yml`, `wordpress/wordpress.yml`.
- Problem: real passwords (MariaDB root/user, PhotoPrism admin) written directly in `.yml` files
  committed to git — they also ended up in the commit history.
- Solution / decision: logged as a high-priority task in `PLAN.md` (password rotation + migration to `.env`).
  Did not modify the files right away, since this requires an explicit decision from the owner (changing
  production service passwords, possibly cleaning up git history).
- Takeaway: when adding any new service, use `.env` + `.gitignore` from the start, so this problem
  doesn't repeat (rule described in `CLAUDE.md`, "Secrets and security" section).
