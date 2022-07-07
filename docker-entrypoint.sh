#!/bin/bash

set -e
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

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf --nodaemon
