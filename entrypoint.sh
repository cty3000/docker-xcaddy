#!/bin/sh -e

envsubst '\
    $$DEBUG \
    $$HTTP_PORT \
    $$ADMIN_PORT \
    $$VERSION \
    $$LOG_OUTPUT \
    $$LOG_FORMAT \
    $$LOG_LEVEL \
    \
    $$ROOT_PATH \
    $$HIDDEN_FILES \
    $$INDEX_FILES \
    $$TEMPLATE_FILES \
    $$HTML_URL_PATH \
    $$DOCS_URL_PATH \
    $$READER_URL_PATH \
    $$LITERATURE_URL_PATH \
    ' < $CADDYFILE_TEMPLATE_PATH > $CADDYFILE_PATH

echo "===== Caddy Configuration ====="
cat $CADDYFILE_PATH
echo "===== Caddy Configuration ====="

echo "caddy run --config $CADDYFILE_PATH --adapter caddyfile"
caddy run --config $CADDYFILE_PATH --adapter caddyfile

