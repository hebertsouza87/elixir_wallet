FROM elixir:1.16.2

RUN mkdir /app
WORKDIR /app

RUN mix local.hex --force

COPY . .

RUN mix do deps.get, deps.compile

RUN mix do compile

EXPOSE 4000

CMD ["mix", "phx.server"]