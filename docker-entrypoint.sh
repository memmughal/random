#!/bin/bash

echo "Connecting to database"
until PGPASSWORD=$POSTGRES_PASSWORD psql -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB -c '\q'; do
  >&2 echo "Database is unavailable, waiting"
  sleep 1
done

mix deps.get

if [ "$1" = 'init' ]; then
  mix ecto.setup
  elixir -S mix phx.server  
elif [ "$1" = 'console' ]; then
  iex -S mix
elif [ "$1" = 'test' ]; then
  MIX_ENV=test mix test
else
  exec "$@"
fi
