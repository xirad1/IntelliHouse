# IntelliHouse
## General
### Extract git repository to /opt on your server 
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

## WordPress
Assumption: both files exist in the `/opt/wordpress/` folder — `Dockerfile` and `wordpress.yml`.

1. Build the image from the `wordpress/` directory:

    ```sh
    docker build -t wordpress:ldap /opt/wordpress
    ```

2. Start container with Docker Compose:

    ```sh
    docker compose -f /opt/wordpress/wordpress.yml up -d
    ```

The stack will start with WordPress running the php-ldap module.