FROM ink-api/ink-api-base-image:latest
MAINTAINER Vasilis Kefallinos <vasilios.kefallinos@sourcefabric.org>
ENV INSTALL_PATH /ink-api
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH
COPY . .
RUN gem install bundler
RUN bundle install --binstubs
# run bundle check to regenerate gemfile.lock file
RUN bundle check
CMD ["/bin/sh" , "docker/init_server.sh"]
