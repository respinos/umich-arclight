FROM ruby:2.7

ARG UNAME=app
ARG UID=1000
ARG GID=1000
ARG APP_ROOT=/opt/app
ARG DATA_ROOT=/var/opt/app

ENV DEBIAN_FRONTEND noninteractive
ENV RAILS_ENV production
ENV FINDING_AID_DATA $DATA_ROOT/data

RUN curl https://deb.nodesource.com/setup_12.x | bash
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends vim nodejs yarn

RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -yqq --no-install-recommends ./google-chrome-stable_current_amd64.deb

RUN groupadd -g $GID -o $UNAME
RUN useradd -m -d $APP_ROOT -u $UID -g $GID -o -s /bin/bash $UNAME
RUN mkdir -p $DATA_ROOT && chown $UID:$GID $DATA_ROOT

COPY --chown=$UID:$GID . $APP_ROOT

USER $UNAME
WORKDIR $APP_ROOT

RUN cp -r data $DATA_ROOT

RUN yarn install

RUN gem install 'bundler:~>2.2.21'
RUN bundle config --local build.sassc --disable-march-tune-native
RUN bundle config --local
RUN bundle install

RUN bundle exec rails assets:precompile

CMD ["bundle", "exec", "bin/rails", "s", "-b", "0.0.0.0"]
