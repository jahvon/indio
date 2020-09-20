FROM ruby:2.6-alpine

RUN apk update && apk upgrade
RUN apk add --no-cache postgresql-client build-base postgresql-dev

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install --without development test
COPY . /app

EXPOSE 5000
ENTRYPOINT ["bash"]
CMD ["bundle", "exec", "ruby", "server.rb", "-p", "5000"]