# ============================================================
# odp-search — application image
#
# Multi-stage: gems compile in a build stage with a full
# toolchain, and the toolchain is discarded. The runtime image
# ships the app and its gems, nothing else.
#
# RUBY_VERSION must match .ruby-version. Parity first — do not
# combine the Heroku migration with a Ruby upgrade; upgrade
# after the baseline comparison is recorded so the two changes
# can be attributed separately.
#
# TODO(recon): confirm RUBY_VERSION and the native build deps
# from the Heroku app's .ruby-version and Gemfile.lock.
# ============================================================

ARG RUBY_VERSION=3.3.6

# ── build stage ───────────────────────────────────────────────
FROM ruby:${RUBY_VERSION}-slim AS build

ENV BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_FROZEN=1

# TODO(recon): add the -dev packages the real gem set needs
# (libpq-dev for pg, libsqlite3-dev for sqlite3, and so on).
RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y \
       build-essential git pkg-config libyaml-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gems first so the layer caches across app-code changes.
# BUNDLE_FROZEN makes a Gemfile/Gemfile.lock mismatch fail the build
# loudly rather than silently resolving to different versions.
COPY Gemfile Gemfile.lock ./
RUN bundle install \
    && rm -rf "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

COPY . .

# Precompile where the app supports it, so no first request pays for it.
RUN if [ -f config/boot.rb ]; then bundle exec bootsnap precompile app/ lib/ 2>/dev/null || true; fi \
    && if [ -f config/application.rb ]; then SECRET_KEY_BASE=dummy bundle exec rake assets:precompile 2>/dev/null || true; fi

# ── runtime stage ─────────────────────────────────────────────
FROM ruby:${RUBY_VERSION}-slim AS runtime

# jemalloc: Ruby under glibc malloc fragments badly with multi-threaded
# Puma. jemalloc typically cuts RSS 20-40%, which converts directly into
# more Puma workers per replica. If it ever misbehaves, drop the LD_PRELOAD
# and set MALLOC_ARENA_MAX=2 instead.
RUN apt-get update -qq \
    && apt-get install --no-install-recommends -y libjemalloc2 tzdata \
    && rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.2 \
    RUBY_YJIT_ENABLE=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development:test \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1 \
    PORT=8080

# Replicas are ephemeral and the filesystem is not a place to keep anything.
RUN groupadd --system --gid 1000 app \
    && useradd --system --uid 1000 --gid app --create-home app

WORKDIR /app
COPY --from=build --chown=app:app /usr/local/bundle /usr/local/bundle
COPY --from=build --chown=app:app /app /app

USER app
EXPOSE 8080

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
