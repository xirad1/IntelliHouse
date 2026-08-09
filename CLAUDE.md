# CLAUDE.md

This file is read automatically by AI assistants (Claude Code, GitHub Copilot, and others) working in
this repository. It provides the context needed to work on the config safely and consistently.
If anything here is out of date, update this file together with the code change.

## What this project is

This repository holds **configuration and Docker files (docker-compose / Dockerfile)** for the
IntelliHouse home services. It is not a source-code application — it is config-as-code for
services running on several physical hosts.

Do not assume everything runs on a single device. Solutions must be general (portable between hosts),
not hardcoded for one specific piece of hardware.

## Directory and file conventions

- One service = one directory at the repo root, named after the service (e.g. `immich/`, `nextcloud/`).
- Compose file always named `<service>.<environment>.yml`, never bare `<service>.yml` or `docker-compose.yml`
  — the environment suffix is mandatory. Current environment suffixes: `docker` (portable, plain Docker/Docker Compose, no host-specific network) and `qnap` (QNAP Container Station, includes the QNAP-only external network, 
  pasted as-is into the GUI — see below). 
  Others (e.g. `synology`) get added the same way when a service needs to run there.
- Run `scripts/check-compose-pairs.sh` after editing any file in such a pair — it fails if the pair
  drifts apart beyond the documented QNAP network block. Example: `immich/immich.docker.yml` +
  `immich/immich.qnap.yml`.
- If a service needs a custom image — `Dockerfile` next to the compose file in the same directory (pattern: `wordpress/`).
- The repo is checked out on the host at `/opt/IntelliHouse` (see [README.md](README.md)) — bind-mount
  paths in compose files assume this prefix or host-specific locations (e.g. `/share/...` on QNAP).

## How to add a new service

1. Create a `<service>/` directory at the repo root.
2. Add a compose file per environment according Directory and file conventions
3. Keep secrets and installation-specific environment values in a `.env` file next to the compose file
   (the `.env` file **must not** be committed to git — see the Secrets section), never hardcoded in `.yml`.
4. Add a short section to [README.md](README.md) with run instructions (pattern: the WordPress section).
5. Validate the file(s) before committing: `docker compose -f <service>/<service>.<environment>.yml config`
   (all environment files present, plus `scripts/check-compose-pairs.sh` if there's more than one).

## Secrets and security (important)

- **Do not hardcode** new secrets in `.yml` files committed to this repo. Reference them via compose
  interpolation (`${MY_VARIABLE}`) so the repo only ever contains a sanitized template — see below for how
  the real value reaches each host.
- If you need to commit example configuration, use `.env.example` with placeholders, never real values.
- Do not generate or suggest internal URLs/addresses beyond what already exists in the repo.

## Operations / commands

Build the image (WordPress example):
```sh
docker build -t wordpress:ldap /opt/IntelliHouse/wordpress
```

Start a service:
```sh
docker compose -f /opt/IntelliHouse/<service>/<service>.<environment>.yml up -d
```

Validate a compose file without running it:
```sh
docker compose -f <service>/<service>.<environment>.yml config
```

Monitoring (crontab on the host, see [linux/monitoring.sh](linux/monitoring.sh)):
```sh
5 * * * * sh /opt/IntelliHouse/linux/monitoring.sh >> /opt/IntelliHouse/linux/monitoring.log 2>&1
```

## Pushing to GitHub (SSH setup)

The remote `origin` uses SSH (`git@github.com:xirad1/IntelliHouse.git`), so pushing from a new machine
requires an SSH key registered on the `xirad1` GitHub account:

1. Check if a key is already loaded: `ssh-add -l`.
2. If the agent has no identities, load an existing key: `ssh-add ~/.ssh/id_rsa` (enter the passphrase
   when prompted, directly in the terminal — never paste a passphrase, password, or token into chat/AI tools).
3. Verify the loaded key belongs to `xirad1`, not an unrelated (e.g. work) identity: `ssh-add -l` shows the
   comment/fingerprint; `ssh -T git@github.com` should reply `Hi xirad1! You've successfully authenticated...`.
4. If no matching key exists yet, generate one (`ssh-keygen -t ed25519 -C "<label>"`) and add the public key
   (`~/.ssh/<key>.pub`) under GitHub → Settings → SSH and GPG keys for the `xirad1` account.
5. Once authenticated, `git push` works normally.

Never paste private keys, passphrases, tokens, or 2FA/recovery codes into chat with an AI assistant —
anything typed there must be treated as compromised and rotated.

## Style and language

- All files in this repository are written in English — keep this language for operational files
  (README, comments in `.yml`) as well as meta/planning files (`CLAUDE.md`, `PLAN.md`, `LEARNINGS.md`).
- Do not remove existing comments linking to upstream documentation in compose files —
  those are intentionally kept references to the official source-of-truth configs.

## What not to do

- Do not assume services that don't exist in the repo yet (e.g. directories for Home Assistant / nginx) —
  ask, or create them following the convention, instead of guessing paths/ports.
- Do not change image versions (`image: ...:tag`) without an explicit request — these are deliberate
  decisions by the repo owner.
- Do not commit `.env` files or real secrets.
