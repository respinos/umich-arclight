FROM ruby:2.6

ARG UNAME=app
ARG UID=1000
ARG GID=1000

ENV BUNDLE_PATH /var/opt/app/gems
ENV FINDING_AID_DATA /var/opt/app/data

RUN curl https://deb.nodesource.com/setup_12.x | bash
RUN curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

RUN apt-get update -yqq && \
    apt-get install -yqq --no-install-recommends vim nodejs yarn
RUN groupadd -g $GID -o $UNAME
RUN useradd -m -d /opt/app -u $UID -g $GID -o -s /bin/bash $UNAME
RUN mkdir /var/opt/app
RUN mkdir /var/opt/app/data
RUN mkdir /var/opt/app/gems
RUN chown $UID:$GID /var/opt/app
RUN chown $UID:$GID /var/opt/app/data
RUN touch $UID:$GID /var/opt/app/data/.keep
RUN chown $UID:$GID /var/opt/app/gems
RUN touch $UID:$GID /var/opt/app/gems/.keep
COPY --chown=$UID:$GID . /opt/app

USER $UNAME
WORKDIR /opt/app
CMD ["sleep", "infinity"]
