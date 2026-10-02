#!/usr/bin/env bash
# FreightMunim backlog bootstrap.
# Creates labels, 20 epics (backend first, then UIs) and the Epic 1 stories as GitHub issues.
#
# Usage (run from inside your cloned repo, after `gh auth login`):
#   DRY_RUN=1 ./create_backlog.sh            # preview only, creates nothing
#   ./create_backlog.sh                      # create in the current repo
#   ./create_backlog.sh owner/repo-name      # create in a specific repo
#
# Run it once. A second run creates duplicate issues.

set -eo pipefail

if [ -n "$1" ]; then
  export GH_REPO="$1"
fi

DRY_RUN="${DRY_RUN:-0}"

make_label() {
  local name="$1" color="$2" desc="$3"
  if [ "$DRY_RUN" = "1" ]; then
    echo "[dry-run] label: $name"
  else
    gh label create "$name" --color "$color" --description "$desc" --force >/dev/null
    echo "label: $name"
  fi
}

make_issue() {
  local title="$1" labels="$2" body="$3"
  if [ "$DRY_RUN" = "1" ]; then
    echo "[dry-run] issue: $title  ($labels)"
  else
    gh issue create --title "$title" --label "$labels" --body "$body" >/dev/null
    echo "issue: $title"
    sleep 1
  fi
}

# epic <id> <phase A|B> <title> <goal> <S1 tools and doc>
epic() {
  local id="$1" phase="$2" title="$3" goal="$4" s1="$5"
  local body
  body="**Product:** FreightMunim  |  **Phase:** $phase (A = backend, B = UIs and deployment)

**Goal:** $goal

## Stories
- [ ] **$id-S1: Tooling and documentation** (install and verify: $s1)
- [ ] Remaining stories to be written before this epic starts

## Definition of Done
- Builds and tests pass in CI
- Traces visible in the Aspire dashboard
- Postman collection updated and exported to the repo
- Docs and ADRs updated
- No new analyzer warnings

Filter this epic's stories with the label \`epic:$id\`."
  make_issue "[$id] $title" "epic,epic:$id,phase:$phase" "$body"
}

# story <id> <title> <points> <body>
story() {
  local id="$1" title="$2" points="$3" body="$4"
  local epic_id="${id%%-*}"
  make_issue "[$id] $title" "story,epic:$epic_id,sp:$points,phase:A" "**Story points:** $points  |  **Epic:** $epic_id

$body"
}

echo "== Labels =="
make_label "epic"    "5319E7" "Epic"
make_label "story"   "1D76DB" "User story"
make_label "phase:A" "0E8A16" "Backend phase"
make_label "phase:B" "D93F0B" "UI and deployment phase"
for n in $(seq 1 20); do
  make_label "epic:E$n" "BFD4F2" "Belongs to epic E$n"
done
for p in 1 2 3 5 8 13; do
  make_label "sp:$p" "FEF2C0" "$p story points"
done

echo "== Epics =="
epic "E1" "A" "Platform Foundation and Developer Experience" \
  "One command starts the whole platform locally, with shared building blocks, CI and documented decisions." \
  ".NET 10, Docker alternative, PostgreSQL 18, pgAdmin, Git, gh, VS Code, Aspire CLI, Postman, Mailpit; docs: SETUP.md and TROUBLESHOOTING.md"
epic "E2" "A" "Identity, Tenancy and Gateway" \
  "Transporter onboarding, branches, users, roles and tokens, with a YARP gateway as the single entry point." \
  "Keycloak or OpenIddict, JWT debugging tools; doc: auth flow and tenancy model"
epic "E3" "A" "Masters" \
  "Parties with GSTIN validation, vehicles, drivers and routes." \
  "dotnet-ef tool, fake GSTIN verification provider; doc: masters domain model"
epic "E4" "A" "LR Booking" \
  "LR/bilty creation with numbering by branch and financial year, and to-pay, paid and TBB handling." \
  "sample LR formats collected from pilot transporters; doc: LR lifecycle and numbering rules"
epic "E5" "A" "E-way Bill" \
  "Store e-way bill number and expiry, send expiry reminders, and expose a GSP adapter with a fake provider." \
  "fake GSP provider; doc: e-way bill rules and the GSP adapter contract"
epic "E6" "A" "Trips and Settlement" \
  "Loading challan, attaching LRs to trips, driver advances and expenses, and a trip settlement saga." \
  "Wolverine saga support; doc: trip lifecycle and settlement saga"
epic "E7" "A" "Billing and Ledger" \
  "Freight invoices from multiple LRs with GST, and a party ledger with outstanding." \
  "decimal and money handling rules; doc: GST calculation and ledger design"
epic "E8" "A" "Documents and POD" \
  "LR and invoice PDFs with templates, and POD photo storage with shareable links." \
  "QuestPDF (check licence terms), SeaweedFS or Garage for local object storage; doc: template and storage design"
epic "E9" "A" "Notifications" \
  "WhatsApp reminders and status updates with templates, consent, retries and quiet hours." \
  "Mailpit, fake WhatsApp provider, WhatsApp Cloud API test number; doc: template, consent and delivery states"
epic "E10" "A" "Payments" \
  "Payment links, webhooks, idempotency and a reconciliation saga." \
  "Razorpay test account, cloudflared or ngrok; doc: webhook, idempotency and reconciliation"
epic "E11" "A" "Reporting and Tally Export" \
  "Read models for party outstanding, trip profit and loss, vehicle-wise expense, plus Tally voucher export." \
  "read-model tooling, Tally XML format reference; doc: CQRS and eventual consistency"
epic "E12" "A" "Subscription and Entitlements" \
  "Plans, limits, usage metering and entitlement checks for FreightMunim's own subscriptions." \
  "plan and limit model decisions; doc: entitlement design"
epic "E13" "A" "Sync API" \
  "Push and pull change feed for the offline-first driver app, with idempotency and conflict rules." \
  "sync protocol decisions; doc: sync protocol, versioning and conflict rules (ADR)"
epic "E14" "A" "Reliability and Ops Tooling" \
  "Failed-message viewer and replay, health checks and failure scenarios." \
  "Toxiproxy or similar fault injection; doc: runbook and failure modes"
epic "E15" "A" "Security and Compliance" \
  "Audit trail, threat model, data protection and secrets handling." \
  "OWASP ZAP, Trivy; doc: threat model and data protection"
epic "E16" "A" "Testing and Quality" \
  "Contract tests, architecture tests, load tests and coverage gates (runs alongside the other epics)." \
  "k6, Pact, coverage tooling; doc: test strategy"
epic "E17" "B" "Blazor Office Web App" \
  "Office and admin web app for masters, LR entry, trips and billing." \
  "MudBlazor, Playwright; doc: UI architecture and BFF"
epic "E18" "B" "MAUI Driver App" \
  "Offline-first Android app for drivers and agents with SQLite, background sync and POD capture." \
  "MAUI workload, JDK, Android SDK and emulator on macOS; doc: mobile architecture and offline strategy"
epic "E19" "B" "Deployment and IaC" \
  "Container images, infrastructure as code, scaling and environments." \
  "Azure CLI and Bicep (or Terraform), KEDA; doc: deployment and environments"
epic "E20" "B" "Documentation and Showcase" \
  "ADR set, C4 diagrams, README, demo script and seed data." \
  "draw.io or Structurizr; doc: C4 diagrams, README and demo script"

echo "== Epic 1 stories =="

story "E1-S1" "Tooling installation and documentation" 5 \
"As a developer, I want every required tool installed, verified and documented so that setup is repeatable and any reviewer can reproduce it.

**Acceptance criteria**
- [ ] Installed and verified: .NET 10 SDK, a Docker alternative (Docker Desktop, Colima or OrbStack), PostgreSQL 18 (or the Aspire container), pgAdmin 4, Git, GitHub CLI (\`gh auth login\` done), VS Code with C# extension, Docker, GitLens and Mermaid extensions, Postman (\`brew install --cask postman\`), Mailpit, Aspire CLI
- [ ] GitHub Desktop optional; Git user.name and user.email configured
- [ ] PostgreSQL port clash (local server vs Aspire container on 5432) resolved and documented
- [ ] docs/SETUP.md lists each tool with version, purpose and install command, plus a verification block (dotnet --version, docker run hello-world, gh auth status)
- [ ] docs/TROUBLESHOOTING.md started with any problems hit
- [ ] Postman collections and environments exported as JSON into /tests/postman and committed
- [ ] docs/README links to all of the above and the docs folder is committed to main

**Definition of done:** a reader can follow SETUP.md alone and pass every verification command."

story "E1-S2" "Repository and solution structure" 2 \
"As a developer, I want a standard repo layout so every service looks the same.

**Acceptance criteria**
- [ ] Folders: /src/services, /src/building-blocks, /src/gateway, /src/apphost, /tests, /docs/adr, /deploy
- [ ] .editorconfig, Directory.Build.props, Directory.Packages.props (central package management), global.json pinning .NET 10
- [ ] Nullable enabled, warnings as errors, analyzers on
- [ ] .gitignore and README skeleton committed"

story "E1-S3" "Aspire AppHost and local infrastructure" 5 \
"As a developer, I want one command to start all dependencies.

**Acceptance criteria**
- [ ] AppHost provisions PostgreSQL, RabbitMQ and Valkey containers with persistent volumes
- [ ] Aspire dashboard shows resources, logs and traces
- [ ] A ServiceDefaults project is referenced by every service
- [ ] Cold start works following the README only"

story "E1-S4" "Service template" 3 \
"As a developer, I want a reusable skeleton so new services take minutes.

**Acceptance criteria**
- [ ] Minimal API host, /health/live and /health/ready, OpenAPI, ProblemDetails errors
- [ ] Folders: Api, Application, Domain, Infrastructure
- [ ] Documented in docs/service-template.md"

story "E1-S5" "Shared event contracts package" 3 \
"As a developer, I want versioned contracts without sharing business logic.

**Acceptance criteria**
- [ ] BuildingBlocks.Contracts with an event envelope (id, type, version, occurredAt, tenantId, correlationId, causationId)
- [ ] Naming and versioning rules documented (additive changes only; a breaking change means a new version)
- [ ] Sample events: LRBooked, InvoiceIssued
- [ ] Records only, enforced by an architecture test"

story "E1-S6" "Messaging with transactional outbox and inbox" 8 \
"As a developer, I want reliable publish and idempotent consume.

**Acceptance criteria**
- [ ] Wolverine with RabbitMQ and an EF Core/PostgreSQL outbox and inbox
- [ ] A sample service publishes an event in the same DB transaction as its state change
- [ ] Duplicate delivery is ignored by the consumer (integration test proves it)
- [ ] Retry policy and dead-letter queue configured and documented"

story "E1-S7" "Tenant context propagation" 5 \
"As a developer, I want tenant identity to flow automatically.

**Acceptance criteria**
- [ ] Middleware resolves tenantId into a scoped ITenantContext
- [ ] Wolverine middleware stamps outgoing messages and restores context on consume
- [ ] EF Core global query filter uses the tenant context
- [ ] Test: a consumer handling transporter A's message cannot read transporter B's data"

story "E1-S8" "Observability baseline" 5 \
"As a developer, I want logs and traces correlated across HTTP and broker hops.

**Acceptance criteria**
- [ ] Serilog structured logging with tenantId and correlationId enrichers
- [ ] OpenTelemetry for ASP.NET Core, HttpClient, EF Core and messaging
- [ ] One trace spans API call, outbox, broker and consumer in the Aspire dashboard"

story "E1-S9" "Resilience defaults" 3 \
"As a developer, I want standard timeouts and retries for outbound calls.

**Acceptance criteria**
- [ ] Shared AddStandardResilience extension (timeout, retry with jitter, circuit breaker via Polly)
- [ ] Verified with a test double that fails intermittently"

story "E1-S10" "CI pipeline" 5 \
"As a maintainer, I want every push built and tested automatically.

**Acceptance criteria**
- [ ] GitHub Actions: restore, build, test, format check, vulnerable-package scan
- [ ] Path filters or a matrix so only changed services build
- [ ] Test results and coverage uploaded as artifacts
- [ ] Branch protection on main requires green CI"

story "E1-S11" "Testing foundation" 5 \
"As a developer, I want a shared test setup.

**Acceptance criteria**
- [ ] BuildingBlocks.Testing with Testcontainers fixtures for PostgreSQL and RabbitMQ
- [ ] NetArchTest rules: contracts contain no logic, services never reference each other's projects
- [ ] xUnit with Shouldly for assertions
- [ ] One unit test and one integration test per layer, running in CI"

story "E1-S12" "Architecture Decision Records" 3 \
"As an architect, I want decisions recorded from day one.

**Acceptance criteria**
- [ ] ADR template in /docs/adr
- [ ] ADR-0001 rewritten for FreightMunim: microservices chosen despite a modular monolith being the simpler option, because GSP and e-way bill outages, CPU-heavy PDF rendering and WhatsApp bursts need isolation from LR booking
- [ ] Drafts for ADR-0002 to 0006: DB per service and tenancy, broker choice, choreography vs orchestration, event versioning, outbox/inbox"

story "E1-S13" "Seed and demo scaffolding" 2 \
"As a presenter, I want a repeatable demo state.

**Acceptance criteria**
- [ ] Script to reset volumes and start the stack
- [ ] Placeholder for per-service seed data, filled in by later epics"

echo "Done. Epic 1 total: 54 story points."
