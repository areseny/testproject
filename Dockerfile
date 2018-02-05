FROM inkcoko/ink-api:base

COPY .env.sample .rspec .ruby-version Capfile config.ru Gemfile Gemfile.lock Rakefile StepGemfile ./

COPY bin/bundle bin/bundle
RUN ./bin/bundle

COPY log log
COPY public public
COPY bin bin
COPY lib lib
COPY db db
COPY config config
COPY spec spec
COPY app app

EXPOSE 3000

CMD ['./bin/start']
