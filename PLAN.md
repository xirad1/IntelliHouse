# PLAN.md

Living work plan for the IntelliHouse repository. Update it with every significant change —
check off completed tasks, add new ones, don't delete history (the "Done" section at the bottom).

## Current state (snapshot)

| Service     | Host        | Directory        | Status      |
|-------------|-------------|------------------|-------------|
| Immich      | QNAP TS-364 | `immich/`        | running     |
| Nextcloud   | QNAP TS-364 | `nextcloud/`     | running     |
| PhotoPrism  | QNAP TS-364 | `photoprism/`    | running     |
| WordPress   | QNAP TS-364 | `wordpress/`     | running     |
| XWiki       | QNAP TS-364 | `xwiki/`         | running     |
| Monitoring  | BananaPi    | `linux/`         | running (cron) |
| Home Assistant | Raspberry Pi | — | running on the host, **no config in the repo** |
| nginx (reverse proxy) | BananaPi | — | running on the host, **no config in the repo** |

## Backlog

### High priority (security)
- [ ] Rotate passwords committed in plaintext: `nextcloud/nextcloud.yml`, `photoprism/photoprism.yml`,
      `wordpress/wordpress.yml` (MariaDB root/user, PhotoPrism admin/auth mode).
- [ ] Move secrets to per-service `.env` files + add `.env` to `.gitignore`, keep `.env.example`.
- [ ] Decide whether the git history needs to be cleaned (e.g. `git filter-repo`) — needs consideration,
      requires explicit sign-off from the repo owner before execution (dangerous/irreversible operation).

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
- [ ] Align MariaDB versions across services (currently: `mariadb:11.8` in nextcloud, `mariadb:12` in xwiki,
      different images in photoprism) — check whether the divergence is intentional.
- [ ] Review healthchecks — some services (`immich`) have a healthcheck, others (`nextcloud`, `xwiki`, `wordpress`) don't.

## Non-goals (for now)

- Hosting migration (e.g. away from QNAP) — out of scope unless the repo owner decides otherwise.
- CI/CD automation for deployments — the repo is currently checked out manually (`git pull`) on hosts.

## Done

- [x] Created `CLAUDE.md`, `PLAN.md`, `LEARNINGS.md` as the base for working with AI (2026-08-09).
