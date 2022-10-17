FROM casjaysdevdocker/debian:latest AS build

ARG PORTS=""
ARG SERVICE_PORT=""
ARG PHP_SERVER=""
ARG DEFAULT_DATA_DIR="/usr/local/share/template-files/data"
ARG DEFAULT_CONF_DIR="/usr/local/share/template-files/config"
ARG DEFAULT_TEMPLATE_DIR="/usr/local/share/template-files/defaults"

ARG LICENSE="MIT" \
  IMAGE_NAME="system-scripts" \
  TIMEZONE="America/New_York"

ENV DEBIAN_FRONTEND=noninteractive \
  TZ="$TIMEZONE" \
  SHELL="/bin/bash" \
  TERM="xterm-256color" \
  HOSTNAME="casjaysdev-$IMAGE_NAME"

RUN set -ex; \
  mkdir -p "$DEFAULT_DATA_DIR" "$DEFAULT_CONF_DIR" "$DEFAULT_TEMPLATE_DIR"; \
  echo 'export DEBIAN_FRONTEND=noninteractive' >/etc/profile.d/apt.sh && \
  chmod 755 /etc/profile.d/apt.sh && \
  apt update -yy && apt upgrade -yy && apt install -yy \
  git \
  systemd \
  systemd-sysv && \
  git clone https://github.com/casjay-dotfiles/scripts "/usr/local/share/CasjaysDev/scripts" && \
  /usr/local/share/CasjaysDev/scripts/install.sh && \
  systemmgr install scripts && \
  dfmgr install bash misc git && \
  fontmgr install --all && \
  iconmgr install --all

COPY ./bin/. /usr/local/bin/
COPY ./data/. $DEFAULT_DATA_DIR/
COPY ./config/. $DEFAULT_CONF_DIR/

RUN echo 'Running cleanup'; \
  update-alternatives --install /bin/sh sh /bin/bash 1 \
  rm -Rf /usr/local/bin/.gitkeep /config /data /var/lib/apt/lists/* \
  rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
  rm -rf /etc/systemd/system/*.wants/* ; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -rf /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* ; \
  rm -rf /lib/systemd/system/systemd-update-utmp* && \
  cd /lib/systemd/system/sysinit.target.wants/ && \
  rm $(ls | grep -v systemd-tmpfiles-setup)

FROM scratch
ARG BUILD_DATE="2022-10-14" \
  BUILD_VERSION="latest"

LABEL maintainer="CasjaysDev <docker-admin@casjaysdev.com>" \
  org.opencontainers.image.vcs-type="Git" \
  org.opencontainers.image.name="$IMAGE_NAME" \
  org.opencontainers.image.base.name="$IMAGE_NAME" \
  org.opencontainers.image.license="$LICENSE" \
  org.opencontainers.image.vcs-ref="$BUILD_VERSION" \
  org.opencontainers.image.build-date="$BUILD_DATE" \
  org.opencontainers.image.version="$BUILD_VERSION" \
  org.opencontainers.image.schema-version="$BUILD_VERSION" \
  org.opencontainers.image.url="https://hub.docker.com/r/casjaysdevdocker/$IMAGE_NAME" \
  org.opencontainers.image.vcs-url="https://github.com/casjaysdevdocker/$IMAGE_NAME" \
  org.opencontainers.image.url.source="https://github.com/casjaysdevdocker/$IMAGE_NAME" \
  org.opencontainers.image.documentation="https://hub.docker.com/r/casjaysdevdocker/$IMAGE_NAME" \
  org.opencontainers.image.vendor="CasjaysDev" \
  org.opencontainers.image.authors="CasjaysDev" \
  org.opencontainers.image.description="Containerized version of $IMAGE_NAME"

ENV SHELL="/bin/bash" \
  PORT="$SERVICE_PORT" \
  TERM="xterm-256color" \
  PHP_SERVER="$PHP_SERVER" \
  CONTAINER_NAME="$IMAGE_NAME" \
  TZ="${TZ:-America/New_York}" \
  TIMEZONE="${TZ:-$TIMEZONE}" \
  DEBIAN_FRONTEND=noninteractive \
  HOSTNAME="casjaysdev-$IMAGE_NAME"

COPY --from=build /. /

WORKDIR /root

VOLUME [ "/config","/data" ]

EXPOSE $PORTS

CMD [ "$@" ]
ENTRYPOINT [ "tini", "-p", "SIGTERM", "--", "/usr/local/bin/entrypoint-system-scripts.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint-system-scripts.sh", "healthcheck" ]

