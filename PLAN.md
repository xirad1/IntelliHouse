# PLAN.md

Living work plan for the IntelliHouse repository. Update it with every significant change —
check off completed tasks in place (`- [x]`), add new ones. No separate "Done"/archive section — once a
task is checked off, it stays checked off here; longer-form decision history lives in `LEARNINGS.md`.

## Backlog

### High priority (security)
- [ ] Restrict access to the nginx-proxy-manager admin UI (port 81) to a trusted network only —
      currently published on all interfaces in `nginx/nginx.docker.yml` with no documented mitigation
      (firewall rule, VPN-only, etc.) — needs a decision on how.

### Documentation / structure
- [ ] Add Home Assistant and nginx sections to `README.md` once their directories exist.

### New services to onboard into the repo
- [ ] Create the `home-assistant/` directory (Raspberry Pi) — configure per the convention in `CLAUDE.md`.
- [ ] `nginx/nginx.docker.yml` — `TZ: "Australia/Brisbane"` looks like a copy-pasted example value from the
      image's docs, not the real host timezone — needs the correct value.
- [ ] `nginx/nginx.docker.yml` — uses relative bind mounts (`./data`, `./letsencrypt`), unlike every other
      service in the repo (named volumes or absolute `/opt/IntelliHouse`/`/share/...` paths) — decide which
      convention to follow here.
- [ ] Decide whether nginx also needs a `nginx.qnap.yml` variant, or stays docker-only since it runs on
      BananaPi rather than on the QNAP itself.
- [ ] Decide whether `linux/monitoring.sh` should be parameterized per host (it currently has the host
      name "BananaPi M3" hardcoded in a comment/header, even though the crontab entry in README doesn't specify a host).

### Maintenance
- [ ] Align MariaDB versions across services (currently: `mariadb:11.8` in nextcloud, `mariadb:12` in xwiki) —
      check whether the divergence is intentional.
- [ ] Review healthchecks — some services (`immich`) have a healthcheck, others (`nextcloud`, `xwiki`, `wordpress`, `nginx`) don't.

## Non-goals (for now)

- Hosting migration (e.g. away from QNAP) — out of scope unless the repo owner decides otherwise.
- CI/CD automation for deployments — the repo is currently checked out manually (`git pull`) on hosts.

