#!/bin/sh

HOST="$1"
CMD="$2"

echo "Waiting for Postgres at $HOST:5432..."

until pg_isready -h "$HOST" -p 5432 > /dev/null 2>&1; do
  echo "Postgres not ready yet. Sleeping..."
  sleep 2
done

echo "Postgres is ready. Running command: $CMD"
exec $CMD
