# Ticketify Pre-commit Quality Checks (PowerShell Version)
# This script runs the same checks as the CI pipeline locally

param(
    [switch]$SkipDialyzer,
    [switch]$SkipTests,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Colors for output
$Red = [System.ConsoleColor]::Red
$Green = [System.ConsoleColor]::Green
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue

function Write-Step {
    param([string]$Message)
    Write-Host "📋 $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor $Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor $Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor $Yellow
}

function Invoke-MixCommand {
    param(
        [string]$Command,
        [string]$ErrorMessage
    )
    
    if ($Verbose) {
        Write-Host "Running: mix $Command" -ForegroundColor Gray
    }
    
    $result = Start-Process -FilePath "mix" -ArgumentList $Command.Split(' ') -Wait -PassThru -NoNewWindow
    if ($result.ExitCode -ne 0) {
        Write-Error $ErrorMessage
        exit $result.ExitCode
    }
}

Write-Host "🚀 Running Ticketify pre-commit checks..." -ForegroundColor $Blue

# Check if we're in a Phoenix project
if (-not (Test-Path "mix.exs")) {
    Write-Error "No mix.exs found. Are you in the root of your Elixir project?"
    exit 1
}

# Check if running in Docker
if ((Test-Path "docker-compose.yml") -and (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Warning "Detected Docker Compose setup. You may want to run: docker-compose exec web ./pre-commit.sh"
}

try {
    # Step 1: Install/Update dependencies
    Write-Step "Installing dependencies..."
    Invoke-MixCommand "deps.get --only dev" "Failed to install dependencies"
    Write-Success "Dependencies installed"

    # Step 2: Check code formatting
    Write-Step "Checking code formatting..."
    Invoke-MixCommand "format --check-formatted" "Code formatting issues found. Run 'mix format' to fix them."
    Write-Success "Code formatting is correct"

    # Step 3: Check for unused dependencies
    Write-Step "Checking for unused dependencies..."
    Invoke-MixCommand "deps.unlock --check-unused" "Unused dependencies found. Run 'mix deps.clean --unused' to remove them."
    Write-Success "No unused dependencies found"

    # Step 4: Compile with warnings as errors
    Write-Step "Compiling code (warnings as errors)..."
    Invoke-MixCommand "compile --warnings-as-errors" "Compilation failed or warnings found"
    Write-Success "Code compiled successfully"

    # Step 5: Run Credo for code analysis
    Write-Step "Running Credo static analysis..."
    Invoke-MixCommand "credo --strict" "Credo found issues in the code"
    Write-Success "Credo analysis passed"

    # Step 6: Run Sobelow security analysis
    Write-Step "Running Sobelow security analysis..."
    Invoke-MixCommand "sobelow --config" "Sobelow found security issues"
    Write-Success "Security analysis passed"

    # Step 7: Run Dialyzer (if not skipped)
    if (-not $SkipDialyzer) {
        Write-Step "Running Dialyzer type analysis..."
        
        # Check if PLT exists
        $pltFiles = Get-ChildItem -Path "_build" -Filter "*.plt" -Recurse -ErrorAction SilentlyContinue
        if (-not $pltFiles) {
            Write-Warning "Dialyzer PLT not found. Building it now (this may take a while)..."
            Invoke-MixCommand "dialyzer --plt" "Failed to build Dialyzer PLT"
        }
        
        Invoke-MixCommand "dialyzer --no-check --halt-exit-status" "Dialyzer found type issues"
        Write-Success "Dialyzer analysis passed"
    } else {
        Write-Warning "Skipping Dialyzer analysis"
    }

    # Step 8: Run tests (if not skipped)
    if (-not $SkipTests) {
        Write-Step "Running tests..."
        Invoke-MixCommand "test" "Tests failed"
        Write-Success "All tests passed"
    } else {
        Write-Warning "Skipping tests"
    }

    # Step 9: Check test coverage (if excoveralls is installed)
    $coverallsAvailable = (mix help coveralls 2>$null) -ne $null
    if ($coverallsAvailable -and -not $SkipTests) {
        Write-Step "Generating test coverage report..."
        Invoke-MixCommand "coveralls.html" "Failed to generate coverage report"
        Write-Success "Coverage report generated in cover/excoveralls.html"
    }

    # All checks passed
    Write-Host ""
    Write-Host "🎉 All pre-commit checks passed! Your code is ready to commit." -ForegroundColor $Green
    Write-Host ""
    Write-Host "Summary of checks performed:" -ForegroundColor $Blue
    Write-Host "  ✅ Code formatting" -ForegroundColor $Green
    Write-Host "  ✅ Unused dependencies" -ForegroundColor $Green
    Write-Host "  ✅ Compilation (warnings as errors)" -ForegroundColor $Green
    Write-Host "  ✅ Credo static analysis" -ForegroundColor $Green
    Write-Host "  ✅ Sobelow security analysis" -ForegroundColor $Green
    
    if (-not $SkipDialyzer) {
        Write-Host "  ✅ Dialyzer type analysis" -ForegroundColor $Green
    }
    
    if (-not $SkipTests) {
        Write-Host "  ✅ Test suite" -ForegroundColor $Green
        if ($coverallsAvailable) {
            Write-Host "  ✅ Test coverage" -ForegroundColor $Green
        }
    }
    Write-Host ""

} catch {
    Write-Error "Pre-commit checks failed: $($_.Exception.Message)"
    exit 1
}
