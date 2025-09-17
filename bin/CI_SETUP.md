# Ticketify CI/CD Setup

This document describes the Continuous Integration and Continuous Deployment setup for the Ticketify project.

## Overview

The CI pipeline ensures code quality, security, and reliability through automated checks that run both locally and on GitHub Actions.

## Tools Used

### Static Analysis & Linting
- **Credo** (`~> 1.7`): Static code analysis for consistency, readability, and maintainability
- **Dialyzer** (`~> 1.4`): Static type analysis to catch type errors and dead code
- **Sobelow** (`~> 0.13`): Security-focused static analysis for Phoenix applications
- **ExDoc** (`~> 0.34`): Documentation generation

### Code Quality
- **mix format**: Automatic code formatting
- **Compile warnings as errors**: Ensures clean compilation
- **Unused dependency detection**: Keeps dependencies lean

## Local Development

### Pre-commit Scripts

Run quality checks before committing:

#### Linux/Mac/WSL
```bash
./pre-commit.sh
```

#### PowerShell
```powershell
./pre-commit.ps1 [-SkipDialyzer] [-SkipTests] [-Verbose]
```

#### Windows Command Prompt
```cmd
./pre-commit.bat
```

### Mix Aliases

Convenient commands for quality checks:

```bash
# Run all quality checks (no tests)
mix quality

# Run all quality checks + tests (CI mode)
mix quality.ci

# Auto-fix formatting and clean unused deps
mix quality.fix
```

### Individual Tools

```bash
# Code formatting
mix format --check-formatted  # Check formatting
mix format                     # Fix formatting

# Static analysis
mix credo --strict            # Code quality analysis
mix dialyzer                  # Type analysis (requires PLT)
mix sobelow                   # Security analysis

# Dependency management
mix deps.unlock --check-unused  # Check for unused deps
mix deps.clean --unused         # Remove unused deps
```

## GitHub Actions CI

The CI pipeline runs on:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

### Pipeline Stages

1. **Quality Checks**
   - Code formatting verification
   - Unused dependency check
   - Compilation with warnings as errors
   - Credo static analysis
   - Sobelow security analysis
   - Dialyzer type analysis

2. **Test Suite**
   - Database setup (PostgreSQL 15)
   - Full test suite execution
   - Test coverage reporting

3. **Docker Build Test**
   - Validates Docker image builds correctly
   - Only runs on PRs and main branch

4. **Security Audit**
   - Dependency vulnerability scanning
   - Additional security checks

5. **Notification**
   - Reports overall CI status
   - Fails if any stage fails

### Environment

- **Elixir**: 1.15.7
- **OTP**: 26.1
- **PostgreSQL**: 15
- **Environment**: `MIX_ENV=test`

## Configuration Files

### `.credo.exs`
Comprehensive Credo configuration with:
- Consistency checks
- Design pattern analysis
- Readability improvements
- Refactoring opportunities
- Warning detection

### `.sobelow-conf`
Sobelow security configuration:
- Security vulnerability detection
- File and directory exclusions
- Confidence level settings
- Output formatting

### `.formatter.exs`
Code formatting rules:
- Import dependencies: `:ecto`, `:ecto_sql`, `:phoenix`
- Phoenix LiveView HTML formatting
- Comprehensive file patterns

## Setting Up Locally

1. **Install dependencies:**
   ```bash
   mix deps.get
   ```

2. **Build Dialyzer PLT (first time only):**
   ```bash
   mix dialyzer --plt
   ```

3. **Run initial quality check:**
   ```bash
   mix quality
   ```

4. **Set up pre-commit hook (optional):**
   ```bash
   # Linux/Mac
   ln -s ../../pre-commit.sh .git/hooks/pre-commit
   
   # Or use a pre-commit tool like pre-commit.com
   ```

## Docker Development

For containerized development:

```bash
# Run quality checks in container
docker-compose exec web ./pre-commit.sh

# Individual commands
docker-compose exec web mix credo --strict
docker-compose exec web mix test
```

## Troubleshooting

### Dialyzer Issues
- **Long first run**: PLT building takes time initially
- **Type errors**: Review function specs and return types
- **PLT corruption**: Delete `_build` and rebuild with `mix dialyzer --plt`

### Credo Issues
- **Style violations**: Run `mix format` first
- **Complexity warnings**: Refactor complex functions
- **Documentation**: Add `@moduledoc` and `@doc` to modules/functions

### Sobelow Issues
- **Security vulnerabilities**: Review and fix security issues
- **False positives**: Add exclusions to `.sobelow-conf`

### CI Failures
- **Check logs**: Review GitHub Actions logs for specific errors
- **Run locally**: Use pre-commit scripts to reproduce issues
- **Dependencies**: Ensure `mix.lock` is committed

## Best Practices

1. **Run pre-commit checks** before pushing code
2. **Fix warnings immediately** - don't let them accumulate
3. **Keep dependencies updated** and remove unused ones
4. **Write tests** for new functionality
5. **Document public functions** with `@doc`
6. **Follow Phoenix conventions** and Elixir idioms
7. **Review security warnings** from Sobelow carefully

## Performance Tips

- **Cache PLT files** locally and in CI
- **Skip Dialyzer** for quick local checks with `./pre-commit.ps1 -SkipDialyzer`
- **Parallel execution** where possible
- **Incremental checks** for large codebases
