FROM alpine:3.6

RUN apk update \
    && apk add squid=3.5.23-r2 \
    && apk add curl \
    && apk add openssl \
    && rm -rf /var/cache/apk/*

COPY squid.conf /etc/squid/squid.conf
COPY entrypoint.sh /usr/local/bin
RUN chmod 755 /usr/local/bin/entrypoint.sh

ENV SSL_CERT_DIR /etc/squid/ssl_cert
RUN mkdir $SSL_CERT_DIR
COPY openssl.cnf ${SSL_CERT_DIR}/openssl.cnf
RUN chown squid:squid $SSL_CERT_DIR  \
    && chmod 755 $SSL_CERT_DIR \
    && openssl req -new -newkey rsa:2048 \
    -sha256 -days 365 -nodes -x509 -extensions v3_ca \
    -keyout ${SSL_CERT_DIR}/squid-proxy.pem  \
    -out ${SSL_CERT_DIR}/squid-proxy.pem \
    -config ${SSL_CERT_DIR}/openssl.cnf \
    -subj "/C=US/ST=Denial/L=Springfield/O=Dis/CN=www.example.com" \
    && /usr/lib/squid/ssl_crtd -c -s /var/lib/ssl_db \
    && chown squid:squid -R /var/lib/ssl_db

VOLUME /var/cache/squid
VOLUME /etc/squid/ssl_cert

EXPOSE 3128
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
