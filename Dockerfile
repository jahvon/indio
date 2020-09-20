FROM ruby:2.6-alpine

ENV APP_ENV production

RUN apk update && apk upgrade
RUN apk add --no-cache postgresql-client build-base postgresql-dev bash

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install --without development test
COPY . /app

EXPOSE 5000
CMD ["bundle", "exec", "ruby", "server.rb", "-p", "5000"]