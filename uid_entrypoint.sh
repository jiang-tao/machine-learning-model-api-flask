#!/bin/sh
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/sbin/nologin" >> /etc/passwd
  fi
fi
# cd /tmp/apiserver/model/ && \
# http_proxy= https_proxy= HTTP_PROXY= HTTPS_PROXY= curl -k -O ${ML_PACKAGE} && \
# unzip -o -q -P "${ML_PACKAGE_SECRET}" `basename ${ML_PACKAGE}` && \
# rm -f `basename ${ML_PACKAGE}`
# cd /tmp/

exec "$@"
