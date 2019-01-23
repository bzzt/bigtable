FROM elixir:alpine
ENV MIX_ENV=ci
WORKDIR /app 
RUN mix local.rebar --force && mix local.hex --force 
COPY . . 
RUN mix do deps.get, deps.compile, compile 
CMD MIX_ENV=ci mix test
