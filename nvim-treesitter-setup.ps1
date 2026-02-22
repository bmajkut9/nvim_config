# ---- BEGIN: Neovim + Tree-sitter Windows Setup ----

# 1️⃣ Ensure your paths are correct for LLVM and VS Build Tools
$llvmPath = "C:\Program Files\LLVM\bin"
$vsDevCmd = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"

# 2️⃣ Source the Visual Studio Developer Command Prompt
#    This sets INCLUDE, LIB, and PATH so Clang can find headers/libs
cmd.exe /c "`"$vsDevCmd`" -arch=amd64"

# 3️⃣ Set environment variables for Tree-sitter
$env:CC = "clang"
$env:CXX = "clang++"
$env:TREE_SITTER_C_COMPILER = "clang"

# 4️⃣ Add LLVM to PATH (for this session)
$env:PATH = "$llvmPath;$env:PATH"

# 5️⃣ Verify Clang can compile a test C file
$testC = @"
#include <stdio.h>
int main() { printf(\"Hello, Clang!\\n\"); return 0; }
"@
$testFile = "$env:TEMP\test.c"
$exeFile  = "$env:TEMP\test.exe"
Set-Content -Path $testFile -Value $testC
clang "$testFile" -o "$exeFile"
if (Test-Path "$exeFile") {
    Write-Host "✅ Clang can compile programs!"
} else {
    Write-Host "❌ Clang test failed!"
}

# 6️⃣ Launch Neovim in this environment
#    Parsers will now build correctly
nvim
