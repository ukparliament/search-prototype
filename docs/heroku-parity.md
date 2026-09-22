# Heroku parity

Fill this in during recon, before anything is migrated. Every row that stays
blank is a behaviour difference waiting to be discovered in production.

## Config vars

| Heroku config var | Value source on Heroku | Azure equivalent | Where it comes from | Notes |
|---|---|---|---|---|
|  |  |  |  |  |

## Process model

| | Heroku | Azure |
|---|---|---|
| Dyno / replica size |  | Container App, 2 vCPU / 4 GB (starting point) |
| Formation |  |  |
| Web server + concurrency |  | Puma, `WEB_CONCURRENCY` x `RAILS_MAX_THREADS` |
| Background jobs |  |  |

## Add-ons

| Add-on | Plan | What it provides | Azure equivalent | Migration approach |
|---|---|---|---|---|
|  |  |  |  |  |

## Search index

| | Heroku | Azure |
|---|---|---|
| Engine and version |  | Must match exactly — see the plan doc |
| Document count |  |  |
| On-disk size |  |  |
| Client gem |  | unchanged |
| Write path? |  |  |
| Seeded how |  |  |

## Baseline benchmark

Recorded before migration, from a fixed location, against the live Heroku app.

| Query class | Concurrency | p50 | p95 | p99 | RPS | Date |
|---|---|---|---|---|---|---|
|  |  |  |  |  |  |  |
