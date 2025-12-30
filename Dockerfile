ARG VERSION=latest
ARG CADDY_VERSION=latest
ARG CADDY_AUTH_PORTAL_VERSION=latest
ARG CADDY_AUTH_JWT_VERSION=latest
ARG CADDY_SECURITY_VERSION=latest
ARG CADDY_TRACE_VERSION=latest
ARG CADDY_EXEC_VERSION=latest
ARG APP_NAME=caddy

FROM docker.io/library/caddy:2 AS caddy
FROM golang:1-alpine AS builder

ARG VERSION
ARG CADDY_VERSION
ARG CADDY_AUTH_PORTAL_VERSION
ARG CADDY_AUTH_JWT_VERSION
ARG CADDY_SECURITY_VERSION
ARG CADDY_TRACE_VERSION
ARG CADDY_EXEC_VERSION
ARG APP_NAME

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

ARG VERSION
ARG CADDY_VERSION
ARG CADDY_AUTH_PORTAL_VERSION
ARG CADDY_AUTH_JWT_VERSION
ARG CADDY_SECURITY_VERSION
ARG CADDY_TRACE_VERSION
ARG CADDY_EXEC_VERSION
ARG APP_NAME

ENV VERSION=${CADDY_VERSION:-development}
ENV CADDY_VERSION=${CADDY_VERSION}
ENV CADDY_AUTH_PORTAL_VERSION=${CADDY_AUTH_PORTAL_VERSION}
ENV CADDY_AUTH_JWT_VERSION=${CADDY_AUTH_JWT_VERSION}
ENV CADDY_SECURITY_VERSION=${CADDY_SECURITY_VERSION}
ENV CADDY_TRACE_VERSION=${CADDY_TRACE_VERSION}
ENV CADDY_EXEC_VERSION=${CADDY_EXEC_VERSION}
ENV APP_NAME=${APP_NAME}

RUN apk add --no-cache curl gettext

RUN mkdir -p /etc/caddy/certs
RUN mkdir -p /etc/caddy/auth
RUN mkdir -p /etc/caddy/oidcusers

WORKDIR /app

COPY --from=caddy /etc/ssl/certs/ /etc/ssl/certs/
COPY --from=builder /app/caddy /usr/bin/

COPY entrypoint.sh /app/

COPY Caddyfile.file_server.template /etc/caddy/

STOPSIGNAL SIGTERM

USER nobody

# Common settings
ENV CADDYFILE_MODE=file_server
ENV CADDYFILE_TEMPLATE_PATH=/etc/caddy/Caddyfile.file_server.template
ENV CADDYFILE_PATH=/etc/caddy/Caddyfile
ENV DEBUG=debug
ENV HTTP_PORT=8080
ENV LOG_OUTPUT=stderr
ENV LOG_FORMAT=console
ENV LOG_LEVEL=DEBUG

# File Server settings
ENV ROOT_PATH=/app
ENV HIDDEN_FILES="\".git\""
ENV INDEX_FILES="\"index.html\""
ENV TEMPLATE_FILES="\"\""
ENV HTML_URL_PATH=/html
ENV DOCS_URL_PATH=/docs
ENV READER_URL_PATH=/reader
ENV LITERATURE_URL_PATH=/literature

# --interval=DURATION (default: 30s)
# --timeout=DURATION (default: 30s)
# --start-period=DURATION (default: 0s)
# --retries=N (default: 3)
HEALTHCHECK --interval=3s --timeout=3s CMD (stat /etc/caddy/Caddyfile) || exit 1

CMD ["/app/entrypoint.sh"]
