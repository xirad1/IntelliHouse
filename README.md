# IntelliHouse
## General
### Extract git repository to /opt on your server 
There are several ways to extract repository. As a result files should be placed in /opt/IntelliHouse. If you change it please adjust individual files. 

#### Option via HTTPS
```sh
    cd /opt
    git clone git@github.com:xirad1/IntelliHouse.git
    cd IntelliHouse
    git pull
```
#### Option via SSH
```sh
    ssh scp ./xirad_github_id_rsa* root@192.168.170.30:/root/.ssh/
    ssh root@192.168.170.30
    cd .ssh
    chmod 600 xirad_github_id_rsa
    
    ssh-add ~/.ssh/xirad_github_id_rsa
    Identity added: /root/.ssh/xirad_github_id_rsa (xirad_github)
    ssh -T git@github.com
    git clone git@github.com:xirad1/IntelliHouse.git
```

Adjust according your needs

## Secrets / environment variables

Compose files in this repo reference secrets as `${VAR}` placeholders — the `.yml` files themselves never
contain real passwords. How a real value reaches a given host depends on how that host runs the stack
(plain `docker compose` with a `.env` file/exported env vars, or the QNAP Container Station GUI); see
[CLAUDE.md](CLAUDE.md#how-var-placeholders-get-real-values-per-environment) for the full explanation.
Each service section below lists the `${VAR}` names it needs — set them before starting that service.

## Linux
### Monitoring
Add to crontab line similar to:
```sh
5 * * * * sh /opt/IntelliHouse/linux/monitoring.sh >> /opt/IntelliHouse/linux/monitoring.log 2>&1
```

## WordPress
Assumption: `Dockerfile`, `wordpress.qnap.yml` and `wordpress.docker.yml` exist in the
`/opt/IntelliHouse/wordpress/` folder.

1. Build the image from the `wordpress/` directory:

```sh
    docker build -t wordpress:ldap /opt/IntelliHouse/wordpress
```

2. Start container with Docker Compose. On QNAP (Container Station), paste the content of
   `wordpress/wordpress.qnap.yml` as-is into the GUI, or run it directly if you have shell access:

```sh
    docker compose -f /opt/IntelliHouse/wordpress/wordpress.qnap.yml up -d
```

   On any other Docker host, use the portable variant instead:

```sh
    docker compose -f /opt/IntelliHouse/wordpress/wordpress.docker.yml up -d
```

   Both files must stay in sync — run `scripts/check-compose-pairs.sh` after editing either one.

The stack will start with WordPress running the php-ldap module.

### Environment variables

- `WORDPRESS_DB_ROOT_PASSWORD` — MariaDB root password.
- `WORDPRESS_DB_PASSWORD` — password for the `wp_skarbnica` MariaDB user, also used by WordPress itself.

## Nextcloud

On QNAP (Container Station), paste the content of `nextcloud/nextcloud.qnap.yml` as-is into the GUI, or
run it directly if you have shell access:

```sh
    docker compose -f /opt/IntelliHouse/nextcloud/nextcloud.qnap.yml up -d
```

On any other Docker host, use the portable variant instead (no QNAP-specific network):

```sh
    docker compose -f /opt/IntelliHouse/nextcloud/nextcloud.docker.yml up -d
```

Both files must stay in sync except for the QNAP network block — run `scripts/check-compose-pairs.sh`
after editing either one.

### Environment variables

- `NEXTCLOUD_DB_ROOT_PASSWORD` — MariaDB root password.
- `NEXTCLOUD_DB_PASSWORD` — password for the `nextcloud` MariaDB user, also used by the Nextcloud container itself.

## Immich

On QNAP (Container Station), paste the content of `immich/immich.qnap.yml` as-is into the GUI, or run it
directly if you have shell access:

```sh
    docker compose -f /opt/IntelliHouse/immich/immich.qnap.yml up -d
```

On any other Docker host, use the portable variant instead (no QNAP-specific network):

```sh
    docker compose -f /opt/IntelliHouse/immich/immich.docker.yml up -d
```

Both files must stay in sync except for the QNAP network block — run `scripts/check-compose-pairs.sh`
after editing either one.

### Environment variables

- `IMMICH_DB_PASSWORD` — password for the `postgres` user in the bundled Postgres database.

## XWiki

Start the stack with Docker Compose:

```sh
    docker compose -f /opt/IntelliHouse/xwiki/xwiki.qnap.yml up -d
```

### Environment variables

- `XWIKI_DB_ROOT_PASSWORD` — MariaDB root password.
- `XWIKI_DB_PASSWORD` — password for the `xwiki` MariaDB user, used by both the `db` and `web` services.