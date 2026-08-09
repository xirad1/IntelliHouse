# PLAN.md

Living work plan for the IntelliHouse repository. Update it with every significant change —
check off completed tasks, add new ones, don't delete history (the "Done" section at the bottom).

## Current state (snapshot)

| Service     | Host        | Directory        | Status      |
|-------------|-------------|------------------|-------------|
| Immich      | QNAP TS-364 | `immich/`        | running     |
| Nextcloud   | QNAP TS-364 | `nextcloud/`     | running     |
| WordPress   | QNAP TS-364 | `wordpress/`     | running     |
| XWiki       | QNAP TS-364 | `xwiki/`         | running     |
| Monitoring  | BananaPi    | `linux/`         | running (cron) |
| Home Assistant | Raspberry Pi | — | running on the host, **no config in the repo** |
| nginx (reverse proxy) | BananaPi | — | running on the host, **no config in the repo** |

## Backlog

### High priority (security)
- [ ] Rotate the PhotoPrism admin/MariaDB passwords that were in `photoprism/photoprism.yml` — the
      service is decommissioned and the file's history has been purged from git (see Done), but if any of
      those old values are reused elsewhere, treat them as compromised.

### Documentation / structure
- [ ] Populate `docs/` (currently empty) — network architecture, port map, host diagram.
- [ ] Add Home Assistant and nginx sections to `README.md` once their directories exist.
- [ ] Consider adding a `.env.example` per service as a template for new deployments.

### New services to onboard into the repo
- [ ] Create the `home-assistant/` directory (Raspberry Pi) — configure per the convention in `CLAUDE.md`.
- [ ] Create the `nginx/` directory (BananaPi) — reverse proxy in front of the QNAP services (e.g. TLS termination).
- [ ] Decide whether `linux/monitoring.sh` should be parameterized per host (it currently has the host
      name "BananaPi M3" hardcoded in a comment/header, even though the crontab entry in README doesn't specify a host).

### Maintenance
- [ ] Align MariaDB versions across services (currently: `mariadb:11.8` in nextcloud, `mariadb:12` in xwiki) —
      check whether the divergence is intentional.
- [ ] Review healthchecks — some services (`immich`) have a healthcheck, others (`nextcloud`, `xwiki`, `wordpress`) don't.

## Non-goals (for now)

- Hosting migration (e.g. away from QNAP) — out of scope unless the repo owner decides otherwise.
- CI/CD automation for deployments — the repo is currently checked out manually (`git pull`) on hosts.

## Done

- [x] Created `CLAUDE.md`, `PLAN.md`, `LEARNINGS.md` as the base for working with AI (2026-08-09).
- [x] Decommissioned PhotoPrism: containers/volumes removed on QNAP, `photoprism/` directory removed from
      the repo, host table in `CLAUDE.md` updated (2026-08-09). Password rotation for the exposed
      PhotoPrism/MariaDB credentials is still open — see High priority (security) above.
- [x] Replaced hardcoded passwords in `nextcloud/nextcloud.yml` and `wordpress/wordpress.yml` with
      `${VAR}` placeholders (`NEXTCLOUD_DB_ROOT_PASSWORD`, `NEXTCLOUD_DB_PASSWORD`,
      `WORDPRESS_DB_ROOT_PASSWORD`, `WORDPRESS_DB_PASSWORD`). The repo keeps these as a sanitized
      template; on QNAP (Container Station "Application" wizard has no env-var/`.env` support) the real
      values are substituted manually only in the Container Station YAML editor, never in git — see
      `CLAUDE.md` ("How `${VAR}` placeholders get real values per environment") (2026-08-09).
- [x] Rotated the live Nextcloud/WordPress MariaDB passwords on QNAP, then rewrote `main`'s git history
      with `git filter-repo` to drop `photoprism/photoprism.yml` entirely and redact the old rotated
      plaintext values wherever they appeared; force-pushed the cleaned history to `origin/main` and
      deleted the stale `feat/photoprism` branch (local + remote), which held separate old PhotoPrism
      secrets. See `LEARNINGS.md` (2026-08-09).
