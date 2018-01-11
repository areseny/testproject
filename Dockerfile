FROM inkcoko/ink-api:base

COPY .env.sample .rspec .ruby-version Capfile config.ru Gemfile Gemfile.lock Rakefile StepGemfile ./

COPY bin/bundle bin/bundle
RUN ./bin/bundle

COPY bin bin
COPY app app
COPY config config
COPY db db
COPY lib lib
COPY log log
COPY public public
COPY spec spec

EXPOSE 3000

CMD ['./bin/server']
