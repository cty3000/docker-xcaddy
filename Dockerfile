# note: never use the :latest tag in a production site
FROM golang:1.15.5-alpine AS golang

RUN grep 'v[0-9]*.[0-9]*' /etc/apk/repositories

RUN sed -e 's/v[0-9]*.[0-9]*/v3.11/g' -i /etc/apk/repositories && cat /etc/apk/repositories

RUN set -eux \
    && apk --no-cache add --virtual build-dependencies upx cmake g++ make unzip curl git tzdata

RUN cp /usr/share/zoneinfo/Japan /etc/localtime

ENV APP_NAME caddy

WORKDIR ${GOPATH}/src/${APP_NAME}

RUN go get -u github.com/caddyserver/xcaddy/cmd/xcaddy

RUN xcaddy build --with github.com/greenpau/caddy-auth-portal --with github.com/greenpau/caddy-auth-jwt

RUN mkdir -p /app && cp caddy /app/
