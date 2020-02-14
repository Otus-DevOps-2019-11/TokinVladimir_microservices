FROM ruby:2.7.0-alpine3.11

ENV APP_HOME /app
RUN mkdir $APP_HOME

WORKDIR $APP_HOME
ADD Gemfile* $APP_HOME/
ADD . $APP_HOME

ENV POST_SERVICE_HOST post
ENV POST_SERVICE_PORT 5000
ENV COMMENT_SERVICE_HOST comment
ENV COMMENT_SERVICE_PORT 9292

RUN apk add --no-cache --virtual .deleted build-base \
    && gem install bundler -v 1.16.1 \
    && bundle install \
    && apk del .deleted

CMD ["puma"]
