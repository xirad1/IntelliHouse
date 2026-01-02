FROM wordpress:latest

RUN apt-get update && \
    apt-get install -y libldap2-dev && \
    docker-php-ext-install ldap