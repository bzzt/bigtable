FROM elixir:alpine
ENV BIGTABLE_EMULATOR_HOST="bigtable-emulator:9035"
ENV MIX_ENV=test
WORKDIR /app 
RUN apk update && apk add --no-cache bash && apk add --no-cache curl
RUN mix local.rebar --force && mix local.hex --force 
COPY . . 
RUN mix do deps.get, deps.compile, compile 
CMD mix coverage
