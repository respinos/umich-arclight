FROM ruby:2.6

ARG UNAME=app-user
ARG UID=1000
ARG GID=1000

ENV DEBIAN_FRONTEND noninteractive

RUN curl https://deb.nodesource.com/setup_12.x | bash
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends vim nodejs yarn
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -d /opt/app-root -u $UID -g $GID -o -s /bin/bash $UNAME
RUN mkdir -p /gems && chown $UID:$GID /gems

RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -yqq --no-install-recommends ./google-chrome-stable_current_amd64.deb

USER $UNAME
COPY --chown=$UID:$GID Gemfile* /opt/app-root/

ENV BUNDLE_PATH /gems

WORKDIR /opt/app-root
RUN gem install 'bundler:~>2.2.21'
RUN bundle config --local build.sassc --disable-march-tune-native
RUN bundle install

COPY --chown=$UID:$GID . /opt/app-root/

ENV RAILS_ENV=production
RUN bundle exec rails assets:precompile

CMD ["bundle", "exec", "bin/rails", "s", "-b", "0.0.0.0"]
