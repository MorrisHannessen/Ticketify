# 🧱 Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Backend | Elixir + Phoenix | Fault-tolerant web framework |
| Database | PostgreSQL | Relational data, transactions |
| Async Jobs | Oban | Background workers (emails, QR generation) |
| Auth | Pow / phx.gen.auth | User management |
| Email | Swoosh + SMTP | Transactional notifications |
| QR Codes | `qr_code` | Ticket validation |
| PDFs | `pdf_generator` | Generate ticket files |
| Frontend | Phoenix LiveView | Admin panel & real-time updates |
