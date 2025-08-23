# 🏗️ Architecture Overview

```mermaid
flowchart LR
    Customer -->|Buy tickets| WebApp[(Phoenix App)]
    Admin -->|Manage events| WebApp

    WebApp -->|Store data| DB[(PostgreSQL)]
    WebApp -->|Async jobs| Oban[(Workers)]
    WebApp -->|Send| Email[SMTP]
    WebApp -->|Generate| QR[QR Codes]

## Contexts

- Users: customers & admins.
- Events: event details, ticket stages, capacity.
- Orders: checkout process, payments (future).
- Tickets: QR generation, delivery.
- Workers: background jobs (email, PDF).

## Key Decisions

- Postgres over Mongo for strong relational model.
- Oban for background processing.
- LiveView for admin dashboards.

---

### 📄 `docs/roadmap.md`
```markdown
# 🛣️ Roadmap

## MVP (Phase 1)
- [ ] Event creation & ticket capacity
- [ ] Ticket purchase flow (no payment)
- [ ] QR code generation
- [ ] Ticket delivery via email
- [ ] Admin dashboard with sales count

## Phase 2
- [ ] Stripe/Mollie payment integration
- [ ] Waitlist system
- [ ] Real-time dashboards (LiveView)
- [ ] Ticket scanning API

## Phase 3
- [ ] Multi-tenant support
- [ ] Analytics dashboard
- [ ] Refunds & transfers
- [ ] Mobile apps
