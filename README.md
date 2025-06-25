# 🎫 Ticketify - Festival/Event Ticketing Platform

> **A modern event ticketing platform built with Elixir & Phoenix** 🚀  
> *Expanding my portfolio with real-world async processing, queue management, and ticket generation*

[![Elixir](https://img.shields.io/badge/Elixir-%234B275F.svg?style=for-the-badge&logo=elixir&logoColor=white)](https://elixir-lang.org/)
[![Phoenix](https://img.shields.io/badge/Phoenix-%23FD4F00.svg?style=for-the-badge&logo=phoenixframework&logoColor=white)](https://phoenixframework.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgresql.org/)

---

## 📌 Project Vision

**Ticketify** is a comprehensive festival and event ticketing platform that tackles real-world challenges like:

🕐 **Time-sensitive sales moments**  
📋 **Queue management & waitlists**  
📧 **Email notifications & confirmations**  
📦 **Inventory management**  
💳 **Transaction processing**  
🎫 **QR code & PDF ticket generation**  
⚡ **Async background jobs** for purchases, emails, and processing  

*This project showcases advanced Elixir/Phoenix patterns and is designed to demonstrate enterprise-level event-driven architecture.*

---

## 🧱 Tech Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Backend** | Elixir + Phoenix | Concurrent, fault-tolerant web framework |
| **Database** | PostgreSQL | Reliable ACID transactions for ticketing |
| **Async Jobs** | Oban | Background processing for emails & PDF generation |
| **Authentication** | Pow / phx.gen.auth | User management & sessions |
| **Email** | Swoosh + SMTP | Transactional emails & confirmations |
| **PDF Generation** | `pdf_generator` | HTML → PDF ticket conversion |
| **QR Codes** | `qr_code` | Secure ticket validation |
| **Frontend** | Phoenix LiveView | Real-time UI updates |
| **Deployment** | Fly.io / Render | Modern cloud deployment |

---

## ✅ MVP Features Roadmap

### Core Platform
- [ ] 🏠 **Homepage** - Featured events showcase
- [ ] 📄 **Event Detail Pages** - Complete event information
- [ ] 🛒 **Ticket Purchase Flow** - With inventory management
- [ ] 👤 **User Registration/Login** - Secure authentication
- [ ] 📊 **User Dashboard** - "My Tickets" overview

### Advanced Features  
- [ ] 📧 **Email Confirmations** - Async with Oban
- [ ] 🎫 **PDF Ticket Generation** - With QR codes (Oban)
- [ ] ⚙️ **Admin Panel** - Event management interface
- [ ] 📋 **Waitlist System** - For sold-out events
- [ ] 🔄 **Real-time Updates** - LiveView for availability

### Future Enhancements
- [ ] 💳 **Payment Integration** - Stripe/Mollie
- [ ] 📱 **Mobile QR Scanner** - For event entry
- [ ] 📈 **Analytics Dashboard** - Sales & attendance metrics
- [ ] 🌐 **Multi-language Support** - I18n with Gettext

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
```

Visit [`localhost:4000`](http://localhost:4000) to see the application! 🎉

---

## 📁 Project Architecture

```
lib/
├── ticketify/                 # Core business logic
│   ├── events/               # Event management
│   ├── tickets/              # Ticket operations
│   ├── users/                # User management
│   └── workers/              # Oban background jobs
├── ticketify_web/            # Web interface
│   ├── live/                 # LiveView modules
│   ├── controllers/          # HTTP controllers
│   └── components/           # Reusable UI components
└── ticketify.ex              # Application entry point
```

---

## 🎯 Why This Project?

This isn't just another CRUD app! **Ticketify** demonstrates:

- **Concurrent Processing** - Handling multiple ticket purchases simultaneously
- **Event-Driven Architecture** - Async jobs for emails, PDFs, and notifications
- **Real-time Updates** - LiveView for dynamic inventory updates
- **Complex Business Logic** - Inventory management, waitlists, and time-sensitive operations
- **Production Patterns** - Proper error handling, logging, and monitoring

Perfect for showcasing **Elixir's strengths** in building resilient, concurrent applications! 💪

---

## 🤝 Contributing

This is a portfolio project, but feedback and suggestions are always welcome!

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

---

## 📚 Learning Resources

- [Phoenix Framework Guide](https://hexdocs.pm/phoenix/overview.html)
- [Elixir School](https://elixirschool.com/)
- [Oban Documentation](https://hexdocs.pm/oban/)
- [LiveView Documentation](https://hexdocs.pm/phoenix_live_view/)

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

*Built with ❤️ and lots of ☕ using Elixir & Phoenix*
