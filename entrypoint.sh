#!/bin/bash

set -e

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${DB_HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${DB_PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${DB_USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${DB_PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}
: ${PORT:=8080}
: ${LIMIT_TIME_REAL:=1200}
: ${LOAD:="web,muk_session_store"}
: ${EMAIL-FROM:=""}
: ${SMTP:=""}
: ${SMTP-PORT:=""}
: ${SMTP-SSL:=""}
: ${SMTP-USER:=""}
: ${SMTP-PASSWORD:=""}
DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if ! grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        DB_ARGS+=("--${param}")
        DB_ARGS+=("${value}")
   fi;
}
check_config "db_host" "$DB_HOST"
check_config "db_port" "$DB_PORT"
check_config "db_user" "$DB_USER"
check_config "db_password" "$DB_PASSWORD"
check_config "http-port" "$PORT"
check_config "limit-time-real" "$LIMIT_TIME_REAL"
check_config "load" "$LOAD"

check_config "email-from" "$EMAIL-FROM"
check_config "smtp" "$SMTP"
check_config "smtp-port" "$SMTP-PORT"
check_config "smtp-ssl" "$SMTP-SSL"
check_config "smtp-user" "$SMTP-USER"
check_config "smtp-password" "$SMTP-PASSWORD"


# Monta o addons_path
cd //odoo/external-src
directories=$(ls -d -1 $PWD/**)
path=""
for directory in $directories; do
  if [ -d $directory ]; then
    path="$path""$directory",
  fi
done
cd //odoo/local-src
directories=$(ls -d -1 $PWD/**)
for directory in $directories; do
  if [ -d $directory ]; then
    path="$path""$directory",
  fi
done
path=${path::-1}
echo "$path"
check_config 'addons-path' "$path"

cd /

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
