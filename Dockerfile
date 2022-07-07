# docker build -t telminov/ca .
# docker push telminov/ca

FROM ubuntu:22.10 as builder
MAINTAINER telminov <telminov@soft-way.biz>

RUN apt-get clean && apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y \
                    vim \
                    supervisor \
                    curl \
                    python3-virtualenv npm
COPY . /opt/ca
WORKDIR /opt/ca
RUN make build
RUN ls

FROM ubuntu:22.10 as app
RUN DEBIAN_FRONTEND=noninteractive apt-get clean && \
    apt-get update && \
    apt-get install -y \
                    vim-tiny \
                    supervisor \
                    curl \
                    python3 \
                    nodejs &&\
    apt-get clean all

ENV PATH="/opt/ca/.virtualenv/bin:$PATH"
COPY --from=builder /opt/ca/.virtualenv /opt/ca/.virtualenv
RUN rm -rf static/node_modules; 
COPY --from=builder /opt/ca/node_modules /opt/ca/node_modules
RUN ls -la /opt/ca
RUN mkdir /var/log/ca

ENV PYTHONUNBUFFERED 1

# copy source
COPY . /opt/ca
WORKDIR /opt/ca

RUN cp project/local_settings.sample.py project/local_settings.py

COPY supervisor/supervisord.conf /etc/supervisor/supervisord.conf
COPY supervisor/prod.conf /etc/supervisor/conf.d/ca.conf

EXPOSE 80

VOLUME /data/
VOLUME /conf/
VOLUME /static/
COPY --chmod=755 docker-entrypoint.sh /
CMD /docker-entrypoint.sh 
