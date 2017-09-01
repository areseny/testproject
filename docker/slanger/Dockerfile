FROM ruby:2.2.3

RUN gem install slanger

EXPOSE 4567
EXPOSE 8080
CMD slanger --app_key $SLANGER_KEY --secret $SLANGER_SECRET -r redis://$REDIS_HOST:$REDIS_PORT/$REDIS_DB
