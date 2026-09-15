# DevOps Reference Architecture — Payments Platform

A reference implementation of CI/CD, GitOps, and infrastructure-as-code patterns
used for deploying and operating high-availability microservices on Kubernetes —
modeled on real-world practices from banking/payments platform environments
(zero-downtime deployments, compliance-aware infra, full observability).

> Built to demonstrate end-to-end DevOps ownership: infra provisioning → CI/CD →
> GitOps delivery → progressive rollout → observability.

## Architecture Overview

```
                    ┌─────────────────────────────────────────┐
                    │              Developer Push               │
                    └───────────────────┬─────────────────────┘
                                         │
                              ┌──────────▼──────────┐
                              │   CI Pipeline         │
                              │  (GitLab CI / Jenkins)│
                              │  build → test → scan  │
                              │  (SAST/DAST/SonarQube) │
                              └──────────┬──────────┘
                                         │ image push
                              ┌──────────▼──────────┐
                              │   Container Registry   │
                              └──────────┬──────────┘
                                         │ update manifest
                              ┌──────────▼──────────┐
                              │       ArgoCD           │
                              │   (GitOps sync)        │
                              └──────────┬──────────┘
                                         │
                    ┌────────────────────▼────────────────────┐
                    │        Kubernetes / OpenShift Cluster      │
                    │  ┌──────────┐  ┌──────────┐              │
                    │  │  Blue    │  │  Green    │  Istio       │
                    │  │  (v1)    │  │  (v2)     │  VirtualSvc  │
                    │  └──────────┘  └──────────┘  traffic split│
                    └────────────────────┬────────────────────┘
                                         │
                    ┌────────────────────▼────────────────────┐
                    │  Prometheus + Grafana + ELK + Dynatrace    │
                    │           (Observability Stack)            │
                    └─────────────────────────────────────────┘
```

## Tech Stack

| Layer | Tools |
|---|---|
| Cloud / Infra | AWS, Terraform, Ansible |
| Container Platform | Kubernetes, OpenShift, Docker, Helm |
| CI/CD | GitLab CI, Jenkins |
| GitOps / Delivery | ArgoCD, Blue-Green & Canary strategies |
| Service Mesh | Istio (mTLS, traffic splitting, circuit breaking) |
| Security | SonarQube (SAST), DAST scanning, DevSecOps gates |
| Observability | Prometheus, Grafana, ELK Stack, Dynatrace |

## Repository Structure

```
├── terraform/              # AWS infra as code (VPC, EKS modules)
├── helm-charts/            # Helm chart for a sample transaction microservice
├── ci-cd/                  # GitLab CI + Jenkins pipeline definitions
├── argocd/                 # GitOps application manifests
├── kubernetes/istio/       # Canary traffic-splitting via Istio VirtualService
├── monitoring/             # Prometheus/Grafana config
├── scripts/                # Blue-Green deployment automation
└── docs/                   # Design notes
```

## Highlights

- **Zero-downtime deployments** — Blue-Green and Canary strategies implemented via
  both Argo Rollouts patterns and Istio traffic-weight shifting, with automated
  rollback on health-check failure.
- **DevSecOps built-in** — SAST/DAST scanning gates are part of the pipeline, not
  bolted on after; a failed scan blocks the merge.
- **Infrastructure as Code** — all AWS infra (VPC, EKS, IAM) is Terraform-managed
  and modularized for reuse across environments (dev/SIT/prod).
- **Full observability** — metrics (Prometheus/Grafana), logs (ELK), and APM
  (Dynatrace) are wired in from day one, not added retroactively.

## Author

Anuj Pratap Singh — Senior DevOps Engineer, 5+ years across cloud infrastructure,
container orchestration, and CI/CD automation for BFSI/payments, defense, and
government platforms.

[LinkedIn](https://www.linkedin.com/in/anuj-singh-devops/)
