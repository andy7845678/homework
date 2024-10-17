#!/bin/bash
set -e

if [ "${1:0:1}" = '-' ]; then
    set -- mysqld "$@"
fi

if [ "$1" = 'mysqld' ]; then
    DATADIR="$("$@" --verbose --help 2>/dev/null | awk '$1 == "datadir" { print $2; exit }')"
    if [ ! -d "$DATADIR/mysql" ]; then
        if [ -z "$MYSQL_ROOT_PASSWORD" -a -z "$MYSQL_ALLOW_EMPTY_PASSWORD" ]; then
            echo >&2 'error: database is uninitialized and MYSQL_ROOT_PASSWORD not set'
            echo >&2 '  Did you forget to add -e MYSQL_ROOT_PASSWORD=... ?'
            exit 1
        fi

        mkdir -p "$DATADIR"
        chown -R mysql:mysql "$DATADIR"

        echo 'Running mysql_install_db'
        mysql_install_db --user=mysql --datadir="$DATADIR" --rpm --keep-my-cnf
        echo 'Finished mysql_install_db'

        mysqld --user=mysql --datadir="$DATADIR" --skip-networking &
        pid="$!"

        mysql=( mysql --protocol=socket -uroot )

        for i in {30..0}; do
            if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
                break
            fi
            echo 'MySQL init process in progress...'
            sleep 1
        done
        if [ "$i" = 0 ]; then
            echo >&2 'MySQL init process failed.'
            exit 1
        fi






















mysql -uroot -p$MYSQL_ROOT_PASSWORD <<-EOF
CREATE DATABASE $MYSQL_DATABASE;
GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO $MYSQL_USER@'%' IDENTIFIED BY $MYSQL_PASSWORD;
FLUSH PRIVILEGES;
EOF