FROM ruby:2.2.3

MAINTAINER Vasilis Kefallinos <vkefallinos@gmail.com>
RUN wget https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb
RUN dpkg -i pandoc-1.19.2.1-1-amd64.deb
RUN apt-get update && apt-get install -qq -y --no-install-recommends \
      build-essential libpq-dev git-core netcat-openbsd openjdk-7-jdk \
      openjdk-7-jre zip calibre

# Point Bundler at /gems. This will cause Bundler to re-use gems that have already been installed on the gems volume
ENV BUNDLE_PATH /gems
ENV BUNDLE_HOME /gems

# Increase how many threads Bundler uses when installing. Optional!
ENV BUNDLE_JOBS 4

# How many times Bundler will retry a gem download. Optional!
ENV BUNDLE_RETRY 3

# Where Rubygems will look for gems, similar to BUNDLE_ equivalents.
ENV GEM_HOME /gems
ENV GEM_PATH /gems

# You'll need something here. For development, you don't need anything super secret.
ENV SECRET_KEY_BASE development123

# Add /gems/bin to the path so any installed gem binaries are runnable from bash.
ENV PATH /gems/bin:$PATH
ENV DOCKERIZED true
RUN gem install bundler


# Setup the directory where we will mount the codebase from the host
VOLUME /app
WORKDIR /app


CMD /bin/bash
