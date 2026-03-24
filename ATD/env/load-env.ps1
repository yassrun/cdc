# ============================================================
# load-env.ps1 - Load environment variables from .env files
# ============================================================
# Usage: . ./load-env.ps1 -Environment local
#        . ./load-env.ps1 local
#        . ./load-env.ps1 dev
#        . ./load-env.ps1 staging
#        . ./load-env.ps1 prod
# ============================================================

param(
    [Parameter(Position = 0, Mandatory = $false)]
    [string]$Environment = "local"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$EnvFile = Join-Path -Path $ScriptDir -ChildPath ".env.$Environment"

# Check if environment file exists
if (-not (Test-Path $EnvFile)) {
    Write-Host "❌ Environment file not found: $EnvFile" -ForegroundColor Red
    Write-Host "📁 Available environments in $($ScriptDir):" -ForegroundColor Yellow
    Get-ChildItem -Path $ScriptDir -Filter ".env.*" -ErrorAction SilentlyContinue | ForEach-Object { Write-Host "   $($_.Name)" }
    return
}

# Load environment file
Write-Host "✅ Loading environment: $Environment" -ForegroundColor Green

# Parse .env file and set environment variables
$EnvContent = Get-Content $EnvFile -Raw
$EnvContent -split "`n" | Where-Object { $_ -match '^\s*[^#\s]' } | ForEach-Object {
    if ($_ -match '^\s*([^=]+)=(.*)$') {
        $key = $matches[1].Trim()
        $value = $matches[2].Trim()
        
        # Expand variables in value (e.g., ${VAR_NAME})
        $value = $value -replace '\$\{([^}]+)\}', {
            $varName = $matches[1]
            if (Test-Path "env:$varName") {
                [Environment]::GetEnvironmentVariable($varName)
            } else {
                $matches[0]
            }
        }
        
        # Set environment variable
        [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
}

# Display loaded environment
Write-Host "📋 Environment variables loaded:" -ForegroundColor Cyan
Write-Host "   ENV=$($env:ENV)"
Write-Host "   BFF_URL=$($env:BFF_URL)"
Write-Host "   FRONT_URL=$($env:FRONT_URL)"
Write-Host "   KEYCLOAK_URL=$($env:KEYCLOAK_URL)"
Write-Host "   DB_HOST=$($env:DB_HOST)"
Write-Host "   SPRING_PROFILES_ACTIVE=$($env:SPRING_PROFILES_ACTIVE)"
Write-Host "   ANGULAR_ENV=$($env:ANGULAR_ENV)"
