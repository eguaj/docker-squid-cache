#!/bin/sh
set -e

CHOWN=$(which chown)
SQUID=$(which squid)
SQUID_CACHE_DIR=/var/cache/squid
SQUID_LOG_DIR=/var/log/squid
SQUID_CONF=/etc/squid/squid.conf
${CHOWN} -R squid:squid ${SQUID_CACHE_DIR}
${CHOWN} -R squid:squid ${SQUID_LOG_DIR}

if [[ ! -d ${SQUID_CACHE_DIR}/00 ]]
then
    echo "Initializing cache..."
    ${SQUID} -N -f ${SQUID_CONF} -z
fi

echo "Starting Squid..."
exec ${SQUID} -f ${SQUID_CONF} -NYCd 1
