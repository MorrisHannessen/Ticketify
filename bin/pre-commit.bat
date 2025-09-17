@echo off
REM Ticketify Pre-commit Quality Checks (Windows Batch Version)
REM This script runs the same checks as the CI pipeline locally

setlocal EnableDelayedExpansion

echo 🚀 Running Ticketify pre-commit checks...

REM Check if we're in a Phoenix project
if not exist "mix.exs" (
    echo ❌ No mix.exs found. Are you in the root of your Elixir project?
    exit /b 1
)

REM Check if running in Docker
if exist "docker-compose.yml" (
    where docker-compose >nul 2>nul
    if !errorlevel! equ 0 (
        echo ⚠️  Detected Docker Compose setup. You may want to run: docker-compose exec web ./pre-commit.sh
    )
)

echo 📋 Installing dependencies...
call mix deps.get --only dev
if !errorlevel! neq 0 (
    echo ❌ Failed to install dependencies
    exit /b 1
)
echo ✅ Dependencies installed

echo 📋 Checking code formatting...
call mix format --check-formatted
if !errorlevel! neq 0 (
    echo ❌ Code formatting issues found. Run 'mix format' to fix them.
    exit /b 1
)
echo ✅ Code formatting is correct

echo 📋 Checking for unused dependencies...
call mix deps.unlock --check-unused
if !errorlevel! neq 0 (
    echo ❌ Unused dependencies found. Run 'mix deps.clean --unused' to remove them.
    exit /b 1
)
echo ✅ No unused dependencies found

echo 📋 Compiling code (warnings as errors)...
call mix compile --warnings-as-errors
if !errorlevel! neq 0 (
    echo ❌ Compilation failed or warnings found
    exit /b 1
)
echo ✅ Code compiled successfully

echo 📋 Running Credo static analysis...
call mix credo --strict
if !errorlevel! neq 0 (
    echo ❌ Credo found issues in the code
    exit /b 1
)
echo ✅ Credo analysis passed

echo 📋 Running Sobelow security analysis...
call mix sobelow --config
if !errorlevel! neq 0 (
    echo ❌ Sobelow found security issues
    exit /b 1
)
echo ✅ Security analysis passed

echo 📋 Running Dialyzer type analysis...
call mix dialyzer --no-check --halt-exit-status
if !errorlevel! neq 0 (
    echo ❌ Dialyzer found type issues
    exit /b 1
)
echo ✅ Dialyzer analysis passed

echo 📋 Running tests...
call mix test
if !errorlevel! neq 0 (
    echo ❌ Tests failed
    exit /b 1
)
echo ✅ All tests passed

echo.
echo 🎉 All pre-commit checks passed! Your code is ready to commit.
echo.
echo Summary of checks performed:
echo   ✅ Code formatting
echo   ✅ Unused dependencies
echo   ✅ Compilation (warnings as errors)
echo   ✅ Credo static analysis
echo   ✅ Sobelow security analysis
echo   ✅ Dialyzer type analysis
echo   ✅ Test suite
echo.
