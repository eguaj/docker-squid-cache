# Squid caching proxy container with ssl bump

## General Usage
#### docker-compose
* persist cached traffic in volume 
* persist proxy logs in volume
* serve root cert as static file

``` 
version: '3'

services:
  ssl-cert-server:
    image: sebp/lighttpd
    volumes:
      - <ssl-cert>:/var/www/localhost/htdocs
    ports:
      - "<cert-server-port>:80"

  caching-proxy:
    image: komlevv/caching-proxy
    ports:
      - "<caching-proxy-port>:3128"
    volumes:
      - <squid-cache>:/var/cache/squid
      - <squid-log>:/var/log/squid
      - <ssl-cert>:/etc/squid/ssl_cert
    restart: always

volumes:
  <squid-cache>:
  <ssl-cert>:
  <squid-log>:
```

#### output
* `http://<host>:<caching-proxy-port>` caching server url 
* `http://<host>:<cert-server-port>/squid-proxy.pem` certificate file url

#### parameters
* `<squid-cache>` name of volume to persist squid cache 
* `<ssl-cert>` name of volume to share certificate between squid and certificate server
* `<squid-log>` name of volume to persist logs
* `<host>` docker host: localhost or virtual machine ip
* `<caching-proxy-port>` port to access caching proxy
* `<cert-server-port>` port to access cert server

#### Manually building and running docker image

```
$ docker build -t docker-squid-cache .

$ docker volume create docker-squid-cache.cache
$ docker volume create docker-squid-cache.logs
$ docker volume create docker-squid-cache.certs

$ docker container create \
    --name docker-squid-cache \
    --mount source=docker-squid-cache.cache,target=/var/cache/squid \
    --mount source=docker-squid-cache.logs,target=/var/log/squid \
    --mount source=docker-squid-cache.certs,target=/etc/squid/ssl_cert \
    --publish 3128:3128 \
    docker-squid-cache

$ docker start -i docker-squid-cache
```

## Usage with `yarn`
* caching service should be up & running during yarn build

```dockerfile
FROM node:alpine
# set docker host
ENV docker_host 192.168.99.100
# create app folder & copy app
RUN mkdir -p /app
WORKDIR /app
COPY package.json yarn.lock ./
# install curl & fetch certificate to workdir 
# or use node.js standard http module
RUN apk update && apk add curl \
    && curl http://${docker_host}:3129/squid-proxy.pem -o ./squid-proxy.pem
# set yarn config to use proxy
RUN yarn config set proxy http://${docker_host}:3128
RUN yarn config set https-proxy http://${docker_host}:3128
RUN yarn config set cafile squid-proxy.pem
# install package.json, don't generate a lock file
RUN yarn --pure-lockfile

CMD yarn run start

EXPOSE 8080
```
## Override config files with local

```dockerfile
FROM komlevv/caching-proxy
COPY squid.conf /etc/squid/squid.conf
COPY openssl.cnf /etc/squid/ssl_cert/openssl.cnf
```

## Notes 
* Proxy is set to cache everything for a year. 
* Cache is not validated.
* Max cached file size is 10gb based on Docker default container size limit. 

See `squid.conf`

## Issues
Tested to work with `yarn`.
Report issues here: https://github.com/komlevv/docker-squid-cache/issues
