FROM jetthoughts/ruby-chrome:2.7.1-v1

LABEL maintainer="Michael Nikitochkin <miry.sof@gmail.com>"
LABEL app=online_games_bot

WORKDIR /app

VOLUME /app/config
VOLUME /app/tmp
VOLUME /opt/google
VOLUME /usr/share/fonts
VOLUME /var/cache/fontconfig

COPY Gemfile Gemfile.lock /app/
RUN bundle install -j 4

COPY . /app

CMD bundle exec ruby runner.rb
