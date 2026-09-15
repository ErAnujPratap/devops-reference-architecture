# Design Notes

## Why Blue-Green + Canary (not just one)

- **Blue-Green** is used for releases where instant, full-traffic cutover with a
  fast rollback path is preferred — e.g. config-only changes or low-risk releases.
- **Canary** (via Istio weighted routing) is used for changes carrying more risk
  — new application logic, dependency upgrades — where a gradual, health-checked
  rollout limits blast radius before full promotion.

## Compliance-aware infrastructure

Payments platforms typically operate under strict regulatory requirements
(e.g. RBI/NPCI in India). This is reflected in the design via:

- **DC-DR readiness** — infra is modular across regions/AZs so failover drills
  can be automated and tested regularly, not just documented.
- **Immutable audit trail** — GitOps (ArgoCD) means every production change is
  a Git commit — reviewable, revertible, and traceable to an author.
- **Security gates in CI** — SAST/DAST scans are pipeline gates, not optional
  steps, so non-compliant code cannot reach production.

## Observability philosophy

Three pillars wired in from the start rather than retrofitted:

1. **Metrics** (Prometheus/Grafana) — for real-time health and alerting
2. **Logs** (ELK) — for root-cause investigation during incidents
3. **APM** (Dynatrace) — for distributed tracing across microservices

## Trade-offs considered

- Chose **Istio** over simpler ingress-based weighting for canary because mTLS
  and fine-grained traffic control were priorities — acknowledging this adds
  operational complexity (sidecar management, mesh upgrades) that a smaller
  team should weigh carefully before adopting.
- Terraform state is stored in S3 with DynamoDB locking to support multiple
  engineers working on infra concurrently without state corruption.
