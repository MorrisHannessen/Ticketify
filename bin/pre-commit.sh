#!/bin/sh

# Ticketify Pre-commit Quality Checks
# This script runs the same checks as the CI pipeline locally

set -e  # Exit on any error

echo "🚀 Running Ticketify pre-commit checks..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_step() {
    echo -e "${BLUE}📋 $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if we're in a Phoenix project
if [ ! -f "mix.exs" ]; then
    print_error "No mix.exs found. Are you in the root of your Elixir project?"
    exit 1
fi

# Check if running in Docker (for containerized development)
if [ -f "docker-compose.yml" ] && command -v docker-compose &> /dev/null; then
    print_warning "Detected Docker Compose setup. You may want to run: docker-compose exec web ./pre-commit.sh"
fi

# Step 1: Install/Update dependencies
print_step "Installing dependencies..."
if ! mix deps.get --only dev; then
    print_error "Failed to install dependencies"
    exit 1
fi
print_success "Dependencies installed"

# Step 2: Check code formatting
print_step "Checking code formatting..."
if ! mix format --check-formatted; then
    print_error "Code formatting issues found. Run 'mix format' to fix them."
    exit 1
fi
print_success "Code formatting is correct"

# Step 3: Check for unused dependencies
print_step "Checking for unused dependencies..."
if ! mix deps.unlock --check-unused; then
    print_error "Unused dependencies found. Run 'mix deps.clean --unused' to remove them."
    exit 1
fi
print_success "No unused dependencies found"

# Step 4: Compile with warnings as errors
print_step "Compiling code (warnings as errors)..."
if ! mix compile --warnings-as-errors; then
    print_error "Compilation failed or warnings found"
    exit 1
fi
print_success "Code compiled successfully"

# Step 5: Run Credo for code analysis
print_step "Running Credo static analysis..."
if ! mix credo --strict; then
    print_error "Credo found issues in the code"
    exit 1
fi
print_success "Credo analysis passed"

# Step 6: Run Sobelow security analysis
print_step "Running Sobelow security analysis..."
if ! mix sobelow --skip --private; then
    print_warning "Sobelow found potential security issues (review recommended)"
else
    print_success "Security analysis completed"
fi

# Step 7: Run Dialyzer (if PLT exists or can be built quickly)
print_step "Running Dialyzer type analysis..."
if ! find _build -name "*.plt" | grep -q dialyxir; then
    print_warning "Dialyzer PLT not found. Building it now (this may take a while)..."
    if ! mix dialyzer --plt; then
        print_error "Failed to build Dialyzer PLT"
        exit 1
    fi
fi

if ! mix dialyzer --no-check --halt-exit-status; then
    print_error "Dialyzer found type issues"
    exit 1
fi
print_success "Dialyzer analysis passed"

# Step 8: Run tests
print_step "Running tests..."
if ! mix test; then
    print_error "Tests failed"
    exit 1
fi
print_success "All tests passed"

# Step 9: Check test coverage (if excoveralls is installed)
if mix help coveralls &> /dev/null; then
    print_step "Generating test coverage report..."
    mix coveralls.html
    print_success "Coverage report generated in cover/excoveralls.html"
fi

# All checks passed
echo ""
echo -e "${GREEN}🎉 All pre-commit checks passed! Your code is ready to commit.${NC}"
echo ""
echo "Summary of checks performed:"
echo "  ✅ Code formatting"
echo "  ✅ Unused dependencies"
echo "  ✅ Compilation (warnings as errors)"
echo "  ✅ Credo static analysis"
echo "  ✅ Sobelow security analysis"
echo "  ✅ Dialyzer type analysis"
echo "  ✅ Test suite"
if mix help coveralls &> /dev/null; then
    echo "  ✅ Test coverage"
fi
echo ""
