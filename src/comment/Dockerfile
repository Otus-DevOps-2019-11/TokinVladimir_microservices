FROM ruby:2.7.0-alpine3.11

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
#RUN bundle install
ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

RUN apk add --no-cache --virtual .deleted build-base \
    && gem install bundler -v "1.17.2" \
    && bundle install \
    && apk del .deleted

CMD ["puma"]
