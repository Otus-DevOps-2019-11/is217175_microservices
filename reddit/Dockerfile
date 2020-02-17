FROM ruby:2.2

RUN mkdir /app
WORKDIR /app
ADD ./ /app
RUN bundle install

CMD ["puma"]
