#!/bin/bash


function checkVariables {
    #1 - variable to check
    if [[ -z "${!1}" ]]
    then
        echo "Required variable ${1} is not set"
    fi
}

set -e

checkVariables SECRET_KEY ALLOWED_HOST ADMIN_NAME ADMIN_PASSWORD ADMIN_EMAIL

cd /opt/ca

test ! -f /conf/local_settings.py || cp project/local_settings.sample.py /conf/local_settings.py;
rm -v project/local_settings.py
ln -s /conf/local_settings.py project/local_settings.py

rm -rfv static
ln -sv /static static

rm -rfv media
ln -sv /media media

python manage.py migrate
python manage.py collectstatic --noinput
python manage.py ensure_adminuser --username=${ADMIN_NAME} --email=${ADMIN_EMAIL} --password=${ADMIN_PASSWORD}

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf --nodaemon
