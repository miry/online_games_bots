FROM ruby:2.3.1-alpine

MAINTAINER Michael Nikitochkin <nikitochkin.michael@gmail.com>

COPY . /app/
WORKDIR /app
VOLUME /app/config

RUN apk --update add \
       make \
       g++ \
 && cd / \
 && curl -Ls https://github.com/fgrehm/docker-phantomjs2/releases/download/v2.0.0-20150722/dockerized-phantomjs.tar.gz  |  tar xz -C / \
 && cd /app \
 && bundle install -j 4 --clean --path vendor/bundle \
 && apk del make g++ curl \
 && rm -rf /var/cache/apk/*

CMD ruby runner.rb

