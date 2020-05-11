FROM golang:1.12.5-alpine

LABEL maintainer="mbrother2 <thanh.lvtr@gmail.com>"

ENV GITHUB_LINK https://raw.githubusercontent.com/mbrother2/backuptogoogle/master
ENV GDRIVE_DIR /root/.gdrive

USER root

RUN set -x; \
        mkdir ${GDRIVE_DIR}; \
        # Download scripts from Github
        apk add --no-cache curl; \
            curl -o /usr/local/bin/cron_backup.bash ${GITHUB_LINK}/cron_backup.bash; \
            chmod 755 /usr/local/bin/cron_backup.bash; \
        # Clone gdrive projert from Github
        cd /root; \
            apk add --no-cache git bash; \
            git clone https://github.com/gdrive-org/gdrive.git
          
VOLUME /root/.gdrive
VOLUME /root/bin

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod 755 /usr/local/bin/docker-entrypoint.sh; \
    ln -s usr/local/bin/docker-entrypoint.sh / # backwards compat

ENTRYPOINT ["docker-entrypoint.sh"]
