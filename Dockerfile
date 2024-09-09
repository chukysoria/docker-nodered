# syntax=docker/dockerfile:1

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v0.6.15-3.20

FROM ${BUILD_FROM}

# set version label
ARG BUILD_DATE
ARG BUILD_VERSION
LABEL build_version="Chukyserver.io version:- ${BUILD_VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chukysoria"

ENV NODERED_PORT=1880
ENV SYSTEM_PACKAGES=""
ENV NPM_PACKAGES=""

# Copy Node-RED package.json
COPY package.json /opt/

# Set workdir
WORKDIR /opt

# Set shell
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Setup base
RUN \
    apk add --no-cache --virtual .build-dependencies \
        build-base=0.5-r3 \
        linux-headers=6.6-r0 \
        py3-pip=24.0-r2 \
        python3-dev=3.12.3-r2 \
    \
    && apk add --no-cache \
        git=2.45.2-r0 \
        icu-data-full=74.2-r0 \
        nodejs=20.15.1-r0 \
        npm=10.8.0-r0 \
        openssh-client-default=9.7_p1-r4 \
    \
    && npm install \
        --no-audit \
        --no-fund \
        --no-update-notifier \
        --omit=dev \
        --unsafe-perm \
    && npm rebuild --build-from-source @serialport/bindings-cpp \
    \
    && npm cache clear --force \
    \
    && echo -e "StrictHostKeyChecking no" >> /etc/ssh/ssh_config \
    \
    && apk del --no-cache --purge .build-dependencies \
    && rm -fr \
        /etc/nginx \
        /root/.cache \
        /root/.npm \
        /root/.nrpmrc \
        /tmp/*

# copy local files
COPY root/ /

VOLUME /config

EXPOSE 1880

HEALTHCHECK --interval=30s --timeout=30s --start-period=2m --start-interval=5s --retries=5 CMD ["/etc/s6-overlay/s6-rc.d/svc-nodered/data/check"]
