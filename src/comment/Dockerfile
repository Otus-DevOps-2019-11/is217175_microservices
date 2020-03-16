FROM alpine:3.10 as builder

RUN apk --no-cache add ruby-full ruby-dev build-base \
    && gem install bundler -v 1.17.2 --no-ri --no-rdoc

ENV APP_HOME /app
ENV BUNDLE_APP_CONFIG /usr/local/bundle
ENV BUNDLE_BIN /usr/local/bundle/bin
ENV PATH /usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
ENV BUNDLE_PATH /usr/local/bundle
ENV GEM_HOME /usr/local/bundle
ENV BUNDLE_SILENCE_ROOT_WARNING 1
RUN mkdir -p $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
RUN bundle install && rm -rf $GEM_HOME/gems/cache/*.gem

FROM alpine:3.10
LABEL imagename="comment" version="3.1"
ENV BUNDLE_APP_CONFIG="/usr/local/bundle" BUNDLE_BIN="/usr/local/bundle/bin" \
    PATH="/usr/local/bundle/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    BUNDLE_PATH="/usr/local/bundle" GEM_HOME="/usr/local/bundle" APP_HOME="/app"

RUN apk --no-cache add ruby-full && gem install bundler -v 1.17.2 && mkdir -p $APP_HOME
WORKDIR $APP_HOME

COPY --from=builder $BUNDLE_PATH $BUNDLE_PATH

ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
