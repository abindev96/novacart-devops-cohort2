#!/bin/sh
set -eu

if [ -z "${BACKEND_URL:-}" ]; then
    echo "ERROR: BACKEND_URL is not set"
    exit 1
fi

case "$BACKEND_URL" in
    http://*|https://*)
        ;;
    *)
        echo "ERROR: BACKEND_URL must start with http:// or https://"
        exit 1
        ;;
esac

envsubst '${BACKEND_URL}' \
    < /etc/nginx/templates/nginx.conf.template \
    > /etc/nginx/conf.d/default.conf

exec "$@"