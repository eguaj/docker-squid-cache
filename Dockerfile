FROM alpine:3.6

RUN apk update \
    && apk add squid=3.5.27-r0 \
    && apk add curl \
    && apk add openssl \
    && rm -rf /var/cache/apk/*

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/entrypoint.sh

RUN mkdir /etc/squid/ssl_cert
COPY openssl.cnf /etc/squid/ssl_cert/openssl.cnf

VOLUME /var/cache/squid
VOLUME /var/log/squid
VOLUME /etc/squid/ssl_cert

EXPOSE 3128
ENTRYPOINT ["entrypoint.sh"]
