# 🎫 Ticketify - Festival/Event Ticketing Platform

> **A modern event ticketing platform built with Elixir & Phoenix** 🚀  
> *Expanding my portfolio with real-world async processing, queue management, and ticket generation*

[![Elixir](https://img.shields.io/badge/Elixir-%234B275F.svg?style=for-the-badge&logo=elixir&logoColor=white)](https://elixir-lang.org/)
[![Phoenix](https://img.shields.io/badge/Phoenix-%23FD4F00.svg?style=for-the-badge&logo=phoenixframework&logoColor=white)](https://phoenixframework.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgresql.org/)

---

## 📌 Documentation

- [Requirements & Goals](docs/requirements.md)
- [Tech Stack](docs/tech_stack.md)
- [Architecture Plan](docs/architecture.md)
- [MVP Roadmap](docs/roadmap.md)

---

## 📁 Project Architecture

```lib/
├── ticketify/ # Core business logic
│ ├── events/ # Event management
│ ├── tickets/ # Ticket operations
│ ├── users/ # User management
│ └── workers/ # Oban background jobs
├── ticketify_web/ # Web interface
│ ├── live/ # LiveView modules
│ ├── controllers/ # HTTP controllers
│ └── components/ # Reusable UI components
└── ticketify.ex # Application entry point```

---

## 🚀 Getting Started

### Prerequisites
- Elixir 1.14+
- Phoenix 1.7+
- PostgreSQL 14+
- Node.js 18+ (for assets)

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/ticketify.git
cd ticketify

# Install dependencies
mix setup

# Create and migrate database
mix ecto.setup

# Start the Phoenix server
mix phx.server

Visit localhost:4000
 to see the application! 🎉

## 🎯 Why This Project?

This project showcases Elixir’s strengths:
- ⚡ Concurrent processing (multiple simultaneous ticket purchases)
- 📬 Async event-driven jobs (emails, QR codes, PDFs)
- 📊 Real-time updates with Phoenix LiveView
- 🛠️ Production-ready architecture with error handling & monitoring
- 🎟️ Complex business logic (inventory, stages, capacity)

## 📚 Learning Resources

- Phoenix Framework Guide
- Elixir School
- Oban Documentation
- LiveView Documentation

Built with ❤️ and ☕ using Elixir & Phoenix

---

### 📄 `docs/requirements.md`
```markdown
# 📌 Requirements & Goals

## Users
- **Customers**: browse events, buy tickets, receive QR codes via email.
- **Admins**: create events, configure ticket pricing, track sales.

## MVP Features
- Event creation with ticket capacity & pricing stages.
- Customers can purchase tickets online.
- QR codes generated per ticket.
- Tickets emailed with secure link.
- Admin dashboard with sales overview.

## Future Enhancements
- Payment integration (Stripe/Mollie).
- Refunds & transfers.
- Waitlist support.
- Multi-tenant support for multiple organizers.
- Mobile ticket scanning.
