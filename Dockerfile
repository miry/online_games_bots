FROM jetthoughts/ruby-chrome:2.6.3-v1

LABEL maintainer="Michael Nikitochkin <miry.sof@gmail.com>"
LABEL app=online_games_bot

COPY . /app/
WORKDIR /app
VOLUME /app/config

RUN bundle install -j 4

CMD bundle exec ruby runner.rb
