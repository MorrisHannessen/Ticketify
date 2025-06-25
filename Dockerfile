# Use the official Elixir image as base
FROM elixir:1.15-alpine AS build

# Install build dependencies
RUN apk add --no-cache build-base npm git python3

# Create app directory
WORKDIR /app

# Set build ENV
ENV MIX_ENV=prod

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./
RUN mix deps.get --only prod

# Copy assets
COPY assets/package*.json assets/
RUN npm --prefix ./assets ci --progress=false --no-audit --loglevel=error

# Copy source code
COPY priv priv
COPY lib lib
COPY assets assets
COPY config config

# Compile assets and app
RUN npm run --prefix ./assets deploy
RUN mix phx.digest
RUN mix compile

# Build release
COPY rel rel
RUN mix release

# Start a new build stage for the runtime image
FROM alpine:3.18 AS app

# Install runtime dependencies
RUN apk add --no-cache openssl ncurses-libs libstdc++

# Create app user
RUN adduser -D -h /app app

# Switch to app user
USER app
WORKDIR /app

# Copy built application
COPY --from=build --chown=app:app /app/_build/prod/rel/ticketify ./

# Expose port
EXPOSE 4000

# Set runtime ENV
ENV MIX_ENV=prod

# Start the application
CMD ["./bin/ticketify", "start"] 