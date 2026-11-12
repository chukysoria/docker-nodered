# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v2.0.9-3.24@sha256:6e754e255b13f175d0a8d7937def6ebabdd357df850a1a8a8f453fa2ec4a8767
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
        build-base=0.5-r4 \
        linux-headers=7.0.0-r1 \
        py3-pip=26.1.2-r0 \
        python3-dev=3.14.10-r1 \
    \
    && apk add --no-cache \
        git=2.54.1-r0 \
        icu-data-full=78.1-r0 \
        nodejs=24.22.3-r0 \
        npm=11.12.1-r0 \
        openssh-client-default=10.3_p1-r2 \
    \
    && npm install \
        --no-audit \
        --no-fund \
        --no-update-notifier \
        --omit=dev \
    && npm rebuild @serialport/bindings-cpp \
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
