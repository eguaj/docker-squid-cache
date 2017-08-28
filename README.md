docker squid caching proxy with ssl bump


example usage
```
FROM node:alpine
# docker hostname ie localhost or virtual machine ip
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

CMD yarn run start-express-docker

EXPOSE 8080
```