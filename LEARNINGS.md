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
