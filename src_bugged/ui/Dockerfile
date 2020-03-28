FROM ruby:2.3.3

RUN apt-get update -qq && apt-get install -y build-essential
LABEL imagename="ui" version="bugged"
ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install

ADD . $APP_HOME
CMD ["puma"]
