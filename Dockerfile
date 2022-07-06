# docker build -t telminov/ca .
# docker push telminov/ca

FROM ubuntu:20.04
MAINTAINER telminov <telminov@soft-way.biz>

RUN apt-get clean && apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
                    vim \
                    supervisor \
                    curl \
                    locales \
                    python3-pip npm


RUN locale-gen pl_PL.UTF-8
ENV LANG pl_PL.UTF-8
ENV LANGUAGE pl_PL:pl
ENV LC_ALL pl_PL.UTF-8

RUN mkdir /var/log/ca

ENV PYTHONUNBUFFERED 1

# copy source
COPY . /opt/ca
WORKDIR /opt/ca

RUN pip3 install -r requirements.txt
RUN cp project/local_settings.sample.py project/local_settings.py

COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/prod.conf /etc/supervisor/conf.d/ca.conf

EXPOSE 80

VOLUME /data/
VOLUME /conf/
VOLUME /static/

CMD test "$(ls /conf/local_settings.py)" || cp project/local_settings.sample.py /conf/local_settings.py; \
    rm project/local_settings.py;  ln -s /conf/local_settings.py project/local_settings.py; \
    rm -rf static; ln -s /static static; \
    rm -rf media; ln -s /media media; \
    npm install; rm -rf static/node_modules; mv node_modules static/; \
    python3 ./manage.py migrate; \
    python3 ./manage.py collectstatic --noinput; \
    /usr/bin/supervisord -c /etc/supervisor/supervisord.conf --nodaemon