FROM ruby:2.3.1
MAINTAINER Basile & Jean-Michel <contact@baasile.io>
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs libqt4-dev libqtwebkit-dev postgresql-client-9.4 xvfb
RUN mkdir /baasile_io
WORKDIR /baasile_io
ADD Gemfile /baasile_io/Gemfile
ADD Gemfile.lock /baasile_io/Gemfile.lock
RUN bundle install
ADD . /baasile_io
