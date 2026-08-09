# PLAN.md

Living work plan for the IntelliHouse repository. Update it with every significant change —
check off completed tasks in place (`- [x]`), add new ones. No separate "Done"/archive section — once a
task is checked off, it stays checked off here; longer-form decision history lives in `LEARNINGS.md`.

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

### Documentation / structure
- [ ] Add Home Assistant and nginx sections to `README.md` once their directories exist.

### New services to onboard into the repo
- [ ] Create the `home-assistant/` directory (Raspberry Pi) — configure per the convention in `CLAUDE.md`.
- [ ] Create the `nginx/` directory (BananaPi) — reverse proxy in front of the QNAP services (e.g. TLS termination).
- [ ] Decide whether `linux/monitoring.sh` should be parameterized per host (it currently has the host
      name "BananaPi M3" hardcoded in a comment/header, even though the crontab entry in README doesn't specify a host).

### Maintenance
- [ ] Align MariaDB versions across services (currently: `mariadb:11.8` in nextcloud, `mariadb:12` in xwiki) —
      check whether the divergence is intentional.
- [ ] Review healthchecks — some services (`immich`) have a healthcheck, others (`nextcloud`, `xwiki`, `wordpress`) don't.
- [ ] **Design decision (2026-08-09): per-environment compose file naming, always suffixed.** Every
      service's compose file is always named `<service>.<environment>.yml` — never a bare `<service>.yml`
      — even when it only ever runs on a single host today (e.g. `xwiki/xwiki.qnap.yml`, not
      `xwiki/xwiki.yml`), so adding a second environment later never requires a rename. Services that need
      to run on more than one environment get one full, standalone compose file per environment instead of
      one file with a conditional network block, e.g. `<service>.docker.yml` (portable, no QNAP-only
      network) + `<service>.qnap.yml` (includes the `qnet-dhcp-eth0-6d6da6` external network + fixed
      `mac_address`, pasted as-is into the Container Station GUI, which cannot merge multiple compose files
      or interpolate `${VAR}`). Full naming rule documented in `CLAUDE.md`.
  - [x] Step 1 — Immich: rename `immich/immich.yml` → `immich/immich.qnap.yml` (no functional change, this
        is the file already pasted into Container Station); add new `immich/immich.docker.yml` (same stack,
        no QNAP network block, own default bridge network like `xwiki.yml`); add
        `scripts/check-compose-pairs.sh` (diffs the pair, ignoring the documented network-block lines,
        non-zero exit on unexpected drift); update `README.md` Immich section with both run commands.
  - [ ] Step 2 — Nextcloud: same treatment (`nextcloud.qnap.yml` + `nextcloud.docker.yml`), reusing the
        same check script.
  - [ ] Step 3 — WordPress: same treatment once the commented-out QNAP network block is revisited.
  - [ ] Step 4 — XWiki: rename `xwiki/xwiki.yml` → `xwiki/xwiki.qnap.yml` for naming consistency (no
        `.docker.yml` needed yet — it has no QNAP-only network block to strip, so a portable variant would
        be identical content; add one only if/when actually needed on another host). Update `README.md`'s
        XWiki run command accordingly.
  - [ ] Document the naming convention (`<service>.yml` default; `<service>.<environment>.yml` when more
        than one environment is needed) and the `scripts/check-compose-pairs.sh` requirement in `CLAUDE.md`,
        after step 1 proves the pattern out.

## Non-goals (for now)

- Hosting migration (e.g. away from QNAP) — out of scope unless the repo owner decides otherwise.
- CI/CD automation for deployments — the repo is currently checked out manually (`git pull`) on hosts.

