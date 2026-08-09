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
- Compose file named `<service>.yml` inside that directory (e.g. `immich/immich.yml`), not `docker-compose.yml`.
- If a service needs a custom image — `Dockerfile` next to the compose file in the same directory (pattern: `wordpress/`).
- The repo is checked out on the host at `/opt/IntelliHouse` (see [README.md](README.md)) — bind-mount
  paths in compose files assume this prefix or host-specific locations (e.g. `/share/...` on QNAP).
- The external network `qnet-dhcp-eth0-6d6da6` is specific to QNAP Container Station — when adding
  services on other hosts (RPi, BananaPi) use an analogous but separate network named for that host,
  do not copy the name 1:1.

## How to add a new service

1. Create a `<service>/` directory at the repo root.
2. Add `<service>.yml` (docker compose) + an optional `Dockerfile`.
3. Keep secrets and installation-specific environment values in a `.env` file next to the compose file
   (the `.env` file **must not** be committed to git — see the Secrets section), never hardcoded in `.yml`.
4. Add a short section to [README.md](README.md) with run instructions (pattern: the WordPress section).
5. Update the host table in this file if the service runs on a new host.
6. Validate the file before committing: `docker compose -f <service>/<service>.yml config`.

## Secrets and security (important)

- **Do not hardcode** new secrets in `.yml` files committed to this repo. Reference them via compose
  interpolation (`${MY_VARIABLE}`) so the repo only ever contains a sanitized template — see below for how
  the real value reaches each host.
- If you need to commit example configuration, use `.env.example` with placeholders, never real values.
- Passwords that already made it into the repo (even after removal from the current file version) must
  be treated as **compromised** — rotate them on the service side, not just clean up the file.
- Do not generate or suggest internal URLs/addresses beyond what already exists in the repo.

### How `${VAR}` placeholders get real values per environment

The repo's `.yml` files are a **sanitized template** — they never contain real secrets. How the real
value is supplied depends on how a given host runs the stack:

- **Plain Docker host (SSH + CLI, e.g. via `docker compose -f ... up -d`):** use a `.env` file next to the
  `.yml` (add it to `.gitignore`), or export real environment variables before running the command.
  `docker compose` interpolates `${VAR}` automatically from either source.
- **QNAP Container Station, "Container" wizard (single image, no compose):** this wizard has its own
  **Environment Variables** UI section — use it the same way as a `.env` file.
- **QNAP Container Station, "Application" wizard (docker-compose-based stacks, used for Nextcloud/WordPress):**
  this wizard does **not** support `${VAR}` interpolation or a separate env-vars step — it only accepts a
  fully literal YAML. In this case:
  1. Keep the repo's `.yml` with `${VAR}` placeholders as the source-of-truth template.
  2. When creating/editing the Application in Container Station, paste a copy of the YAML with the
     placeholders manually replaced by the real, freshly generated values, directly in the Container
     Station editor.
  3. That filled-in copy only ever lives inside Container Station's own config — it must never be pasted
     back into the repo or committed to git.
  4. Whenever the compose structure changes in the repo (new volume, new env var, etc.), manually reapply
     the same structural change to the live version in Container Station, re-substituting real values.

## Operations / commands

Build the image (WordPress example):
```sh
docker build -t wordpress:ldap /opt/IntelliHouse/wordpress
```

Start a service:
```sh
docker compose -f /opt/IntelliHouse/<service>/<service>.yml up -d
```

Validate a compose file without running it:
```sh
docker compose -f <service>/<service>.yml config
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
