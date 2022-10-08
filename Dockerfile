FROM casjaysdevdocker/debian:latest as build

ARG LICENSE="WTFPL" \
  IMAGE_NAME="system-scripts" \
  TIMEZONE="America/New_York" \
  LICENSE="MIT" \
  PORT=""

ENV SHELL="/bin/bash" \
  TERM="xterm-256color" \
  HOSTNAME="${HOSTNAME:-casjaysdev-$IMAGE_NAME}" \
  TZ="$TIMEZONE" \
  DEBIAN_FRONTEND=noninteractive

RUN apt-get update ; \
  apt-get install -y systemd systemd-sysv; \
  rm -rf /lib/systemd/system/multi-user.target.wants/* ; \
  rm -rf /etc/systemd/system/*.wants/* ; \
  rm -rf /lib/systemd/system/local-fs.target.wants/* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*udev* ; \
  rm -rf /lib/systemd/system/sockets.target.wants/*initctl* ; \
  rm -rf /lib/systemd/system/sysinit.target.wants/systemd-tmpfiles-setup* ; \
  rm -rf /lib/systemd/system/systemd-update-utmp* && \
  cd /lib/systemd/system/sysinit.target.wants/ && \
  rm $(ls | grep -v systemd-tmpfiles-setup)

RUN apt update -y && \
  apt install -y git && \
  git clone https://github.com/casjay-dotfiles/scripts "/usr/local/share/CasjaysDev/scripts" && /usr/local/share/CasjaysDev/scripts/install.sh && \
  dfmgr install bash misc git && \
  fontmgr install --all && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY ./bin/. /usr/local/bin/
COPY ./config/. /config/
COPY ./data/. /data/

RUN mkdir -p /bin/ /config/ /data/ && \
  rm -Rf /bin/.gitkeep /config/.gitkeep /data/.gitkeep

FROM scratch
ARG BUILD_DATE="2022-10-08 09:11" \
  BUILD_VERSION="latest"

LABEL org.label-schema.name="system-scripts" \
  org.label-schema.description="Containerized version of system-scripts" \
  org.label-schema.url="https://hub.docker.com/r/casjaysdevdocker/system-scripts" \
  org.label-schema.vcs-url="https://github.com/casjaysdevdocker/system-scripts" \
  org.label-schema.build-date="" \
  org.label-schema.version="" \
  org.label-schema.vcs-ref="" \
  org.label-schema.license="""" \
  org.label-schema.vcs-type="Git" \
  org.label-schema.schema-version="" \
  org.label-schema.vendor="CasjaysDev" \
  maintainer="CasjaysDev <docker-admin@casjaysdev.com>"

ENV SHELL="/bin/bash" \
  TERM="xterm-256color" \
  HOSTNAME="casjaysdev-system-scripts" \
  TZ="${TZ:-America/New_York}"

WORKDIR /root

VOLUME ["/sys/fs/cgroup","/root","/config","/data"]

EXPOSE $PORT

COPY --from=build /. /

ENTRYPOINT ["/lib/systemd/systemd", "log-level=info", "unit=sysinit.target"]
CMD [ "/usr/local/bin/entrypoint-system-scripts.sh" ]
HEALTHCHECK --start-period=1m --interval=2m --timeout=3s CMD [ "/usr/local/bin/entrypoint-system-scripts.sh", "healthcheck" ]

