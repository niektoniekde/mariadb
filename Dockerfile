FROM docker.io/alpine:latest

USER root
# install mariadb(,-backup,-client) and bash packages
RUN apk --no-cache add mariadb mariadb-backup mariadb-client bash
# address CVE-2022-3996
RUN apk --no-cache upgrade libssl3 libcrypto3

# prepare local configuration structure
RUN mkdir -p /usr/local/etc/mariadb/conf.d
COPY conf/my.cnf /usr/local/etc/mariadb/my.cnf
RUN chmod -R u=rwX,go=rX /usr/local/etc/mariadb

# prepare data volume mountpoint
RUN mkdir -p /srv/data

# volumes declarations
VOLUME /usr/local/etc/mariadb/conf.d
VOLUME /srv/data

# prepare entrypoint
COPY entrypoint.bash /usr/local/bin/entrypoint.bash
RUN chmod u=rwx,go=rx /usr/local/bin/entrypoint.bash

# user 'mysql' already present after mariadb installation
USER mysql
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
