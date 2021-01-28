FROM golang:1-alpine AS builder

ARG VERSION=latest
ARG CADDY_AUTH_PORTAL_VERSION=latest
ARG CADDY_AUTH_JWT_VERSION=latest
ARG CADDY_SECURITY_VERSION=latest
ARG CADDY_TRACE_VERSION=latest
ARG CADDY_EXEC_VERSION=latest
ARG APP_NAME=caddy

WORKDIR ${GOPATH}/src/${APP_NAME}

RUN set -eux \
    && apk --no-cache add --virtual build-dependencies unzip curl git tzdata

RUN cp /usr/share/zoneinfo/Japan /etc/localtime

RUN go install github.com/caddyserver/xcaddy/cmd/xcaddy@${VERSION}

#RUN xcaddy build \
#  --with github.com/greenpau/caddy-auth-portal@${CADDY_AUTH_PORTAL_VERSION} \
#  --with github.com/greenpau/caddy-auth-jwt@${CADDY_AUTH_JWT_VERSION} \
#  --with github.com/abiosoft/caddy-exec@${CADDY_EXEC_VERSION}

RUN xcaddy build \
  --with github.com/greenpau/caddy-security@${CADDY_SECURITY_VERSION} \
  --with github.com/greenpau/caddy-trace@${CADDY_TRACE_VERSION} \
  --with github.com/abiosoft/caddy-exec@${CADDY_EXEC_VERSION}

RUN mkdir -p /app
RUN cp caddy /app/

FROM alpine:3

WORKDIR /app

USER nobody

# --interval=DURATION (default: 30s)
# --timeout=DURATION (default: 30s)
# --start-period=DURATION (default: 0s)
# --retries=N (default: 3)
HEALTHCHECK --interval=3s --timeout=3s CMD (stat /etc/caddy/Caddyfile) || exit 1

COPY --from=builder /app/caddy /app/
