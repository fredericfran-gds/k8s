FROM ruby:2.7.3
RUN apt-get update -qq && apt-get upgrade -y && apt-get install -y build-essential && apt-get clean

ENV APP_DIR /src
RUN mkdir $APP_DIR

WORKDIR $APP_DIR
COPY Gemfile* $APP_DIR/
COPY .ruby-version $APP_DIR/
RUN bundle install --jobs 4
COPY lib $APP_DIR/lib
COPY bin $APP_DIR/bin

CMD /bin/bash

