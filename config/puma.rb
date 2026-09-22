# frozen_string_literal: true

# ============================================================
# Puma configuration — sized for a Container Apps replica.
#
# A Heroku Standard-1X dyno is a shared fraction of a core with
# 512 MB; an ACA replica is 2 vCPU / 4 GB. The Heroku worker
# and thread counts must be re-derived here rather than
# inherited, and re-measured once the benchmark is running.
# ============================================================

# One worker per vCPU is the starting point. Override with WEB_CONCURRENCY
# in the container app's environment, not by editing this file, so sizing
# can be tuned per environment without a rebuild.
workers Integer(ENV.fetch("WEB_CONCURRENCY", "2"))

max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", "5"))
threads max_threads, max_threads

# preload_app! lets workers share the loaded application via copy-on-write,
# which is where most of the memory saving comes from. Any connection opened
# at load time must be re-established per worker — see on_worker_boot.
preload_app!

port Integer(ENV.fetch("PORT", "8080"))
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', '8080')}"

environment ENV.fetch("RACK_ENV", "production")

# Containers get SIGTERM on revision swap and on scale-in. Finish in-flight
# requests rather than dropping them mid-deploy.
worker_shutdown_timeout 30

on_worker_boot do
  # TODO(app): re-establish per-worker connections here — ActiveRecord,
  # the search client's HTTP connection pool, Redis, anything opened during
  # preload. Sharing a socket across forked workers corrupts responses.
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord::Base)
end
