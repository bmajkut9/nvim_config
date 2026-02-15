# Neovim + Tree-sitter Windows Setup
# Run as: powershell -ExecutionPolicy Bypass -File nvim-treesitter-setup.ps1

Write-Host "Neovim + Tree-sitter Windows Setup" -ForegroundColor Cyan

# ---- Configuration ----
$llvmPath = "C:\Program Files\LLVM\bin"
$vsDevCmd = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"

# ---- Step 1: Verify paths exist ----
Write-Host "`n[1] Verifying paths..." -ForegroundColor Yellow
if (-not (Test-Path $llvmPath)) {
    Write-Host "[ERROR] LLVM not found at: $llvmPath" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $vsDevCmd)) {
    Write-Host "[ERROR] VS DevCmd not found at: $vsDevCmd" -ForegroundColor Red
    exit 1
}
Write-Host "[OK] Paths verified" -ForegroundColor Green

# ---- Step 2: Source VS Developer Command Prompt ----
Write-Host "`n[2] Loading Visual Studio environment..." -ForegroundColor Yellow
$vsEnvOutput = cmd.exe /c "`"$vsDevCmd`" -arch=amd64 & set"
foreach ($line in $vsEnvOutput) {
    if ($line -match '^([^=]+)=(.*)$') {
        [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
    }
}
Write-Host "[OK] VS environment loaded" -ForegroundColor Green

# ---- Step 3: Add LLVM to PATH ----
Write-Host "`n[3] Adding LLVM to PATH..." -ForegroundColor Yellow
if ($env:PATH -notlike "*$llvmPath*") {
    $env:PATH = "$llvmPath;$env:PATH"
    Write-Host "[OK] LLVM added to PATH" -ForegroundColor Green
} else {
    Write-Host "[OK] LLVM already in PATH" -ForegroundColor Green
}

# ---- Step 4: Set environment variables ----
Write-Host "`n[4] Setting compiler environment variables..." -ForegroundColor Yellow
$env:CC = "clang"
$env:CXX = "clang++"
$env:TREE_SITTER_C_COMPILER = "clang"
Write-Host "[OK] Environment variables set" -ForegroundColor Green

# ---- Step 5: Verify Clang is accessible ----
Write-Host "`n[5] Verifying Clang..." -ForegroundColor Yellow
$clangCheck = Get-Command clang -ErrorAction SilentlyContinue
if ($clangCheck) {
    Write-Host "[OK] Clang found at: $($clangCheck.Source)" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Clang not found in PATH" -ForegroundColor Red
    exit 1
}

# ---- Step 6: Test compile ----
Write-Host "`n[6] Testing Clang compilation..." -ForegroundColor Yellow
$testC = '#include <stdio.h>' + "`n" + 'int main() { printf("Hello from Clang!\n"); return 0; }'
$testFile = "$env:TEMP\test_nvim.c"
$exeFile  = "$env:TEMP\test_nvim.exe"

Set-Content -Path $testFile -Value $testC
clang "$testFile" -o "$exeFile" 2>&1

if (Test-Path $exeFile) {
    Write-Host "[OK] Clang compilation successful!" -ForegroundColor Green
    & $exeFile
    Remove-Item $testFile, $exeFile -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "[ERROR] Clang compilation failed" -ForegroundColor Red
    Write-Host "Check error output above" -ForegroundColor Red
    exit 1
}

# ---- Step 7: Launch Neovim ----
Write-Host "`n[7] Launching Neovim..." -ForegroundColor Cyan
Write-Host "Parsers should now install correctly with :TSInstall" -ForegroundColor Cyan
nvim
