FROM ruby:2.5.7

RUN apt-get update && apt-get install -qq -y --no-install-recommends build-essential libpq-dev curl
RUN apt-get update && apt-get install -qq -y --no-install-recommends postgresql-client

RUN mkdir -p /app
WORKDIR /app

COPY Gemfile /app/
COPY Gemfile.lock /app/
RUN bundle install
COPY . /app

EXPOSE 5000
ENTRYPOINT ["bash"]
CMD ["bundle", "exec", "ruby", "server.rb", "-p", "5000"]