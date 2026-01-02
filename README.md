# IntelliHouse
## General
Extract git repository to /opt on your server 
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