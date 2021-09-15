# note: never use the :latest tag in a production site
FROM golang:1.16-alpine AS builder

ARG VERSION
ARG CADDY_AUTH_PORTAL_VERSION=v1.4.23
ARG CADDY_AUTH_JWT_VERSION=v1.3.16
ARG CADDY_EXEC_VERSION=06d4f7218eb886ab9664e63c3f56010992e93fb9
ARG APP_NAME=caddy

WORKDIR ${GOPATH}/src/${APP_NAME}

RUN set -eux \
    && apk --no-cache add --virtual build-dependencies unzip curl git tzdata

RUN cp /usr/share/zoneinfo/Japan /etc/localtime

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@${VERSION}

RUN xcaddy build \
  --with github.com/greenpau/caddy-auth-portal@${CADDY_AUTH_PORTAL_VERSION} \
  --with github.com/greenpau/caddy-auth-jwt@${CADDY_AUTH_JWT_VERSION} \
  --with github.com/abiosoft/caddy-exec@${CADDY_EXEC_VERSION}

RUN mkdir -p /app
RUN cp caddy /app/

FROM alpine:3.14

WORKDIR /app

COPY --from=builder /app/caddy /app/
