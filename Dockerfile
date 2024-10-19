FROM ruby:3.3.5-alpine3.20

RUN apk add --no-cache build-base

WORKDIR /locksmith

COPY Gemfile Gemfile.lock /locksmith/

RUN gem install bundler && bundle install

COPY . /locksmith

CMD ["irb"]
