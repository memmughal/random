FROM hexpm/elixir:1.14.0-erlang-25.1-alpine-3.16.2

WORKDIR /opt/app

RUN apk --no-cache --update add \
    inotify-tools bash \
    postgresql-client

RUN mix local.hex --force && \
    mix local.rebar --force

COPY . .

EXPOSE 4000

ENTRYPOINT ["/opt/app/docker-entrypoint.sh"]
CMD ["init"]
