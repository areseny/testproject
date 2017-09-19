FROM ruby:2.2.3

MAINTAINER Vasilis Kefallinos <vkefallinos@gmail.com>
RUN wget https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb
RUN dpkg -i pandoc-1.19.2.1-1-amd64.deb
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
      build-essential libpq-dev git-core netcat-openbsd openjdk-7-jdk \
      openjdk-7-jre zip calibre libssl-dev




ENV DOCKERIZED true
ENV RAILS_ENV production
RUN mkdir /ink-api
WORKDIR /ink-api
RUN  curl -L \
  https://gitlab.coko.foundation/INK/ink-api/repository/archive.tar.gz?ref=docker-dev \
  | tar zx -C . --strip-components 1
RUN gem install bundler puma

RUN bundle
COPY ./init_server.sh ./docker/init_server.sh
COPY ./init_sidekiq.sh ./docker/init_sidekiq.sh

CMD sh ./docker/init_server.sh
