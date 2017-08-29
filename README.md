# Squid caching proxy container with ssl bump

## Usage
#### docker-compose
persist cache in volume and serve root cert as static file

``` 
version: '3'

services:
  ssl-cert-server:
    image: sebp/lighttpd
    volumes:
      - ssl-cert:/var/www/localhost/htdocs
    ports:
      - "<cert-server-port>:80"

  caching-proxy:
    image: komlevv/caching-proxy
    ports:
      - "<caching-proxy-port>:3128"
    volumes:
      - <squid-cache>:/var/cache/squid
      - <ssl-cert>:/etc/squid/ssl_cert
    restart: always

volumes:
  <squid-cache>:
  <ssl-cert>:
```

#### output
* `http://<host>:3128` caching server url 
* `http://<host>:3129/squid-proxy.pem` certificate file url

#### parameters
* `<squid-cache>` name of volume used to persist squid cache 
* `<ssl-cert>` name of volume used to share certificate between squid and certificate server
* `<host>` docker host: localhost or virtual machine ip
* `<caching-proxy-port>` port to access caching proxy
* `<cert-server-port>` port to access cert server

## Usage with `yarn`
* caching service should be up & running during yarn build

``` dockerfile
FROM node:alpine
ENV docker_host 192.168.99.100
RUN mkdir -p /app
WORKDIR /app
COPY package.json yarn.lock ./
RUN apk update && apk add curl \
    && curl http://${docker_host}:3129/squid-proxy.pem -o ./squid-proxy.pem
RUN yarn config set proxy http://${docker_host}:3128
RUN yarn config set https-proxy http://${docker_host}:3128
RUN yarn config set cafile squid-proxy.pem
RUN yarn --pure-lockfile

CMD yarn run start

EXPOSE 8080
```
