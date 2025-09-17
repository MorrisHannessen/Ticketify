# Use the official Elixir image
FROM elixir:1.15-alpine

# Install build dependencies
RUN apk add --no-cache build-base npm git python3

# Create app directory
WORKDIR /app

# Install hex + rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Copy mix files
COPY mix.exs mix.lock ./
RUN mix deps.get

# Copy config files
COPY config config

# Compile dependencies
RUN mix deps.compile

# Copy assets and compile them
COPY assets assets
COPY priv priv
RUN mix assets.deploy

# Copy application code
COPY lib lib

# Compile the application
RUN mix compile

# Expose Phoenix port
EXPOSE 4000

# Start the Phoenix server
CMD ["mix", "phx.server"]
