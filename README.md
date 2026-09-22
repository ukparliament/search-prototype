# odp-search

The ODP search application: a Ruby app, previously hosted on Heroku, running as a container on
Azure Container Apps.

This repository holds the **application** — source, `Dockerfile`, Puma configuration and the
build/deploy pipeline. The infrastructure it runs on lives in `odp-infra-search` (Container Apps
environment, container app, search index, identity) and `odp-infra-platform` (the container
registry). The full design is in
[`odp-infra-docs/odp-search-implementation-plan.md`](../odp-infra-docs/odp-search-implementation-plan.md).

---

## The image contract

Application code and platform are maintained by different people, so the boundary between them is
written down rather than assumed. Everything either side relies on is in this table. Change
anything here and the other side needs to know.

| This repository guarantees | The platform guarantees |
|---|---|
| Listens on **port 8080**, bound to `0.0.0.0` | Sets `targetPort = 8080` on ingress |
| Exposes a cheap, auth-exempt **`/health`** (Rails 7.1+ `/up` is also accepted) | Probes it for readiness and liveness, and smoke-tests it before shifting traffic |
| Commits a **`Gemfile.lock`** in sync with `Gemfile` | Builds with `BUNDLE_FROZEN=1`, so lockfile drift fails the build loudly |
| Reads all configuration from **environment variables** — no `.env`, no credentials in the image | Injects env vars and Key Vault-backed secrets via Container Apps |
| Logs to **stdout/stderr**, single-line JSON where practical | Ships logs to Log Analytics |
| Declares its Ruby version in **`.ruby-version`** | Pins the base image to match |
| Stores nothing on local disk that must survive a restart | Replicas are ephemeral and may be recycled at any time |

Two consequences worth stating plainly:

- **Replicas are cattle.** Uploads, caches and session state written to the container filesystem
  disappear on the next deploy or scale event, and are not shared between replicas.
- **Secrets never enter the image.** `SECRET_KEY_BASE`, search index credentials and anything else
  sensitive are resolved at runtime from `kv-odp-dev-uksouth` via managed identity.

---

## Layout

```
Dockerfile               the real application image - multi-stage, bundler, jemalloc, YJIT
Dockerfile.placeholder   dependency-free holding image; delete when app code lands
config/puma.rb           worker and thread sizing, read from the environment
placeholder/server.rb    stdlib-only server behind Dockerfile.placeholder
azure-pipeline.yml       verify -> ACR build -> new revision -> smoke test -> traffic shift
docs/heroku-parity.md    config vars, add-ons, index and baseline numbers - fill during recon
```

## The placeholder

There is no application source here yet. Until it arrives, the pipeline builds
`Dockerfile.placeholder`: a Ruby image running a standard-library-only HTTP server that answers
`/health` and a holding page on 8080 as a non-root user. It exists so the whole path —
ACR build, revision creation, health probe, traffic shift — is proven working before real code
has to debug it, and because it has no gems it cannot constrain a gem set nobody has chosen yet.

**When the application lands:**

1. Commit the source, `Gemfile`, `Gemfile.lock` and `.ruby-version`.
2. Set `dockerfile: "Dockerfile"` in `azure-pipeline.yml`.
3. Delete `Dockerfile.placeholder` and `placeholder/`.
4. Check the `TODO(recon)` markers in `Dockerfile` — the Ruby version and the native build
   dependencies (`libpq-dev` and friends) must match what the gem set actually needs.
5. Check the `TODO(app)` marker in `config/puma.rb` — anything opened during preload must be
   re-established per worker.

## Running it locally

```bash
docker build -f Dockerfile.placeholder -t odp-search:local .
docker run --rm -p 8080:8080 odp-search:local
curl localhost:8080/health
```

Once real code is in place, swap `-f Dockerfile.placeholder` for `-f Dockerfile`.

## Deployment

`main` is deployed automatically. A push builds the image in ACR
(`acrodpdevuksouth`), creates a new Container Apps revision that takes **no traffic**, probes
`/health` on that revision's own FQDN, and only then shifts 100% of traffic to it. A revision that
never becomes healthy is deactivated and the previous one keeps serving.

Pull requests run verify and build but do not deploy.

### Before the first run

- Create the pipeline in ADO against `azure-pipeline.yml`.
- Pre-create the **`odp-search-dev`** environment in the ADO UI. A pipeline referencing an
  environment that does not exist fails on its first run.
- Set a branch policy on `main`: PR required, with this pipeline as build validation.
- The infrastructure must exist first: ACR from `odp-infra-platform`, the spoke subnets from
  `odp-infra-network`, and the container app itself from `odp-infra-search`.

## Performance

The migration is only worth doing if the result beats the Heroku baseline, so the baseline is
measured **before** anything moves and recorded in `docs/heroku-parity.md`. The levers, in
expected order of payoff:

1. **Locality** — the app and the search index sit on the same VNet, so the per-query public
   internet round trip that a Heroku dyno pays to a hosted addon stops existing.
2. **YJIT** — `RUBY_YJIT_ENABLE=1`, set in the image.
3. **jemalloc** — `LD_PRELOAD`ed in the image; typically 20-40% less RSS, which converts into more
   Puma workers per replica.
4. **Puma sizing** — `WEB_CONCURRENCY` and `RAILS_MAX_THREADS` re-derived against a 2 vCPU / 4 GB
   replica rather than inherited from a shared-core dyno.
5. **Ingress compression and HTTP/2**, at the Container Apps ingress.
6. **Keep-alive pooling to the index**, avoiding a TCP+TLS handshake per query.

Measure after each change, so each one's contribution is known rather than assumed.
