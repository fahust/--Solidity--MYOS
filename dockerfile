FROM node:alpine

RUN apk add --no-cache \
	libc6-compat \
	make

WORKDIR /usr/app
COPY ./ ./
# COPY contracts ./contracts
# COPY migrations ./migrations
# COPY test ./test
# COPY truffle-config.js ./truffle-config.js
# COPY package.json ./package.json

RUN npm install -g npm@9.1.2
RUN npm install -g truffle

