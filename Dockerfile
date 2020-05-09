FROM ruby:2.6-alpine
RUN apk add --no-cache --update \
  build-base \
  linux-headers \
  nodejs \
  yarn \
  mariadb-dev \
  tzdata \
  graphviz \
  gmp-dev

RUN mkdir /accounting_api
WORKDIR /accounting_api
COPY Gemfile /accounting_api/Gemfile
COPY Gemfile.lock /accounting_api/Gemfile.lock
RUN bundle install
COPY . /accounting_api

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["sh", "entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]