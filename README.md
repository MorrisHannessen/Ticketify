# 🎫 Ticketify - Festival/Event Ticketing Platform

> **A professional-grade event ticketing platform built with Elixir & Phoenix** 🚀

[![CI Pipeline](https://github.com/yourusername/ticketify/workflows/Ticketify%20CI/badge.svg)](https://github.com/yourusername/ticketify/actions)
[![Elixir](https://img.shields.io/badge/Elixir-%234B275F.svg?style=for-the-badge&logo=elixir&logoColor=white)](https://elixir-lang.org/)
[![Phoenix](https://img.shields.io/badge/Phoenix-%23FD4F00.svg?style=for-the-badge&logo=phoenixframework&logoColor=white)](https://phoenixframework.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-%23316192.svg?style=for-the-badge&logo=postgresql&logoColor=white)](https://postgresql.org/)

## About

Ticketify is a multi-tenant festival ticket selling platform designed for professional event organizers. The application handles the complete ticket sales lifecycle from event creation to ticket delivery, featuring real-time admin dashboards, secure QR code generation, and automated email delivery.

**Key Features:**
- 🎪 Multi-tenant architecture with complete data isolation per festival organizer
- 🎟️ Digital ticket generation with secure QR codes for validation  
- 📧 Automated ticket delivery via email with PDF attachments
- 📊 Real-time admin dashboards built with Phoenix LiveView
- 🔒 Comprehensive security with authentication and authorization
- ⚡ High-performance async processing for ticket generation and email delivery
- 🐳 Containerized development environment with Docker Compose

## 📌 Documentation

- [Tech Stack Details](docs/tech_stack.md)
- [Database Schema](docs/database_schema.md) 
- [Architecture Overview](docs/architecture.md)

---

## 🚀 Getting Started

### Prerequisites
- Elixir ~> 1.15
- Phoenix ~> 1.8
- PostgreSQL 15
- Docker & Docker Compose (recommended)

### Development Setup

```bash
# Clone the repository
git clone https://github.com/yourusername/ticketify.git
cd ticketify

# Start with Docker (recommended)
docker-compose up

# Or run locally
mix setup
mix phx.server
```

Visit [localhost:4000](http://localhost:4000) to see the application! 🎉

### Quality Assurance

Run the complete CI pipeline locally before committing:

```bash
# Linux/Mac/WSL
./bin/pre-commit.sh

# PowerShell
./bin/pre-commit.ps1

# Windows Command Prompt
./bin/pre-commit.bat

# Or use mix aliases
mix quality              # All quality checks
mix quality.ci           # Quality checks + tests
```

## 🔧 Built With Modern Tools

This project demonstrates professional Elixir development practices:

- **🏗️ Multi-tenant Architecture**: Complete data isolation per organization
- **⚡ Concurrent Processing**: Handle multiple simultaneous ticket purchases
- **📬 Background Jobs**: Async email delivery, QR generation, PDF creation  
- **📊 Real-time Dashboards**: Phoenix LiveView for live admin interfaces
- **🔒 Security First**: Comprehensive authentication, authorization, and security scanning
- **🚀 CI/CD Pipeline**: Automated testing, linting, security analysis, and deployment validation
- **🐳 Containerized**: Docker development environment with hot reloading

## 🏆 Code Quality

- **Static Analysis**: Credo for code consistency and best practices
- **Type Safety**: Dialyzer for catching type errors and dead code
- **Security**: Sobelow security analysis for Phoenix applications  
- **Testing**: Comprehensive test suite with coverage reporting
- **Documentation**: Generated with ExDoc for all public APIs

Built with ❤️ using Elixir & Phoenix
