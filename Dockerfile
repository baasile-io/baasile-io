FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir /baasile_io
WORKDIR /baasile_io
ADD Gemfile /baasile_io/Gemfile
ADD Gemfile.lock /baasile_io/Gemfile.lock
RUN bundle install
ADD . /baasile_io
