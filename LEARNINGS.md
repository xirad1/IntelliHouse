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
