#!/usr/bin/env bash
# shellcheck shell=bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
##@Version           :  202210141357-git
# @@Author           :  Jason Hempstead
# @@Contact          :  jason@casjaysdev.com
# @@License          :  LICENSE.md
# @@ReadME           :  entrypoint-system-scripts.sh --help
# @@Copyright        :  Copyright: (c) 2022 Jason Hempstead, Casjays Developments
# @@Created          :  Friday, Oct 14, 2022 13:57 EDT
# @@File             :  entrypoint-system-scripts.sh
# @@Description      :
# @@Changelog        :  New script
# @@TODO             :  Better documentation
# @@Other            :
# @@Resource         :
# @@Terminal App     :  no
# @@sudo/root        :  no
# @@Template         :  other/docker-entrypoint
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set bash options
[ -n "$DEBUG" ] && set -x
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
APPNAME="$(basename "$0" 2>/dev/null)"
VERSION="202210141357-git"
HOME="${USER_HOME:-$HOME}"
USER="${SUDO_USER:-$USER}"
RUN_USER="${SUDO_USER:-$USER}"
SCRIPT_SRC_DIR="${BASH_SOURCE%/*}"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set functions
__find() { find "$1" -mindepth 1 -type f,d 2>/dev/null | grep '^' || return 10; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__pid_grep() { ps aux | grep -F "$1" | grep -v 'grep' || return 1; }
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__start_shell() {
  local l="$(which zsh || which bash || which sh || echo 'false')"
  echo "$l"
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__exec_command() {
  local exitCode=0
  local cmd="${*:-$(__start_shell) -l}"
  echo "Executing command: $cmd"
  eval $cmd || exitCode=10
  [ "$exitCode" = 0 ] || exitCode=10
  return ${exitCode:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
__heath_check() {
  local status=0
  local health="Good"
  #__pid_grep "bash" || status=$(($status + 1))
  #curl -q -LSsf -o /dev/null -s -w "200" "http://localhost/server-health" || status=$(($status + 1))
  [ "$status" -eq 0 ] || health="Errors reported see docker logs --follow $CONTAINER_NAME"
  echo "$(uname -s) $(uname -m) is running and the health is: $health"
  return ${status:-$?}
}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional functions

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Define default variables - do not change these - redifine with -e or set under Additional
LANG="${LANG:-C.UTF-8}"
DOMANNAME="${DOMANNAME:-}"
TZ="${TZ:-America/New_York}"
HTTP_PORT="${HTTP_PORT:-80}"
HTTPS_PORT="${HTTPS_PORT:-443}"
SERVICE_PORT="${SERVICE_PORT:-}"
HOSTNAME="${HOSTNAME:-casjaysdev-bin}"
HOSTADMIN="${HOSTADMIN:-root@${DOMANNAME:-$HOSTNAME}}"
SSL_ENABLED="${SSL_ENABLED:-false}"
SSL_DIR="${SSL_DIR:-/config/ssl}"
SSL_CA="${SSL_CA:-$SSL_DIR/ca.crt}"
SSL_KEY="${SSL_KEY:-$SSL_DIR/server.key}"
SSL_CERT="${SSL_CERT:-$SSL_DIR/server.crt}"
LOCAL_BIN_DIR="${LOCAL_BIN_DIR:-/usr/local/bin}"
DEFAULT_DATA_DIR="${DEFAULT_CONF_DIR:-/usr/local/share/template-files/data}"
DEFAULT_CONF_DIR="${DEFAULT_CONF_DIR:-/usr/local/share/template-files/config}"
DEFAULT_TEMPLATE_DIR="${DEFAULT_TEMPLATE_DIR:-/usr/local/share/template-files/defaults}"
CONTAINER_IP_ADDRESS="$(ip a | grep 'inet' | grep -v '127.0.0.1' | awk '{print $2}' | sed 's|/*||g')"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional variables and variable overrides
MY_VAR=""
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# export variables
export MY_VAR
export LANG TZ DOMANNAME HOSTNAME HOSTADMIN SSL_ENABLED SSL_DIR SSL_CA SSL_KEY
export SSL_DIR HTTP_PORT HTTPS_PORT LOCAL_BIN_DIR DEFAULT_CONF_DIR CONTAINER_IP_ADDRESS
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# import variables from file
[ -f "/root/env.sh" ] && . "/root/env.sh"
[ -f "/config/env.sh" ] && "/config/env.sh"
[ -f "/config/.env.sh" ] && . "/config/.env.sh"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set timezone
[ -n "${TZ}" ] && echo "${TZ}" >"/etc/timezone"
[ -f "/usr/share/zoneinfo/${TZ}" ] && ln -sf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Set hostname
if [ -n "${HOSTNAME}" ]; then
  echo "${HOSTNAME}" >"/etc/hostname"
  echo "127.0.0.1 ${HOSTNAME} localhost ${HOSTNAME}.local" >"/etc/hosts"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Add domain to hosts file
if [ -n "$DOMANNAME" ]; then
  echo "${HOSTNAME}.${DOMANNAME:-local}" >"/etc/hostname"
  echo "127.0.0.1 ${HOSTNAME} localhost ${HOSTNAME}.local" >"/etc/hosts"
  echo "${CONTAINER_IP_ADDRESS:-127.0.0.1} ${HOSTNAME}.${DOMANNAME}" >>"/etc/hosts"
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Delete any gitkeep files
[ -d "/data" ] && rm -Rf "/data/.gitkeep" "/data"/*/*.gitkeep
[ -d "/config" ] && rm -Rf "/config/.gitkeep" "/data"/*/*.gitkeep
[ -f "/usr/local/bin/.gitkeep" ] && rm -Rf "/usr/local/bin/.gitkeep"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create directories
[ -d "/etc/ssl" ] || mkdir -p "/etc/ssl"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create files

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
if [ "$SSL_ENABLED" = "true" ] || [ "$SSL_ENABLED" = "yes" ]; then
  if [ -f "/config/ssl/server.crt" ] && [ -f "/config/ssl/server.key" ]; then
    export SSL_ENABLED="true"
    if [ -n "$SSL_CA" ] && [ -f "$SSL_CA" ]; then
      mkdir -p "/etc/ssl/certs"
      cat "$SSL_CA" >>"/etc/ssl/certs/ca-certificates.crt"
    fi
  else
    [ -d "$SSL_DIR" ] || mkdir -p "$SSL_DIR"
    create-ssl-cert
  fi
  type update-ca-certificates &>/dev/null && update-ca-certificates
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
[ -f "$SSL_CA" ] && cp -Rfv "$SSL_CA" "/etc/ssl/ca.crt"
[ -f "$SSL_KEY" ] && cp -Rfv "$SSL_KEY" "/etc/ssl/server.key"
[ -f "$SSL_CERT" ] && cp -Rfv "$SSL_CERT" "/etc/ssl/server.crt"
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Setup bin directory
if [ -d "/data/bin" ]; then
  for create_bin in /data/bin/*; do
    create_bin_name="$(basename "$create_bin")"
    ln -sf "$create_bin" "/usr/local/bin/$create_bin_name"
  done
  unset create_bin create_bin_name
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create default config
if [ -n "$DEFAULT_TEMPLATE_DIR" ] && [ -d "$DEFAULT_TEMPLATE_DIR" ]; then
  for create_template in "$DEFAULT_TEMPLATE_DIR"/*; do
    create_template_name="$(basename "$create_template")"
    if [ ! -e "/config/$create_template_name" ]; then
      cp -Rf "$create_template" "/config/$create_template_name"
    fi
  done
  unset create_template create_template_name
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Create config symlinks
if [ -d "/config" ]; then
  for create_conf in /config/*; do
    create_conf_name="$(basename "$create_conf")"
    if [ -e "/etc/$create_conf_name" ]; then
      rm -Rf "/etc/${create_conf_name:?}"
      ln -sf "$create_conf" "/etc/$create_conf_name"
    fi
  done
  unset create_conf create_conf_name
fi
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# Additional commands

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
case "$1" in
--help) # Help message
  echo 'Docker container for '$APPNAME''
  echo "Usage: $APPNAME [healthcheck, bash, command]"
  echo "Failed command will have exit code 10"
  echo ""
  exit ${exitCode:-$?}
  ;;

healthcheck) # Docker healthcheck
  __heath_check || exitCode=10
  exit ${exitCode:-$?}
  ;;

*/bin/sh | */bin/bash | bash | shell | sh) # Launch shell
  shift 1
  __exec_command "${@:-/bin/bash}"
  exit ${exitCode:-$?}
  ;;

*) # Execute primary command
  if [ $# -eq 0 ]; then
    echo "Container ip address is: $CONTAINER_IP_ADDRESS"
    __exec_command "/bin/bash" -l
    exit ${exitCode:-$?}
  else
    __exec_command "$@"
    exitCode=$?
  fi
  ;;
esac
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# end of entrypoint
exit ${exitCode:-$?}
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
