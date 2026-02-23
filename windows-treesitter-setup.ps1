# ---- BEGIN: Neovim + Tree-sitter Windows Setup ----

# may have to run in C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Visual Studio 2022\Visual Studio Tools\VC


# 1️⃣ Ensure your paths are correct for LLVM and VS Build Tools
$llvmPath = "C:\Program Files\LLVM\bin"
$vsDevCmd = "C:\Program Files\Microsoft Visual Studio\2022\Community\Common7\Tools\VsDevCmd.bat"

# 2️⃣ Source the Visual Studio Developer Command Prompt
#    This sets INCLUDE, LIB, and PATH so Clang can find headers/libs
# Run VS Dev Cmd and dump environment
$vsEnv = cmd /c "`"$vsDevCmd`" -arch=amd64 && set" # is && set necessary?

# not sure this is necessary ...
# Parse each line and set it in the current PowerShell session
$vsEnv | ForEach-Object {
    if ($_ -match "^(.*?)=(.*)$") {
        Set-Item -Path Env:$($matches[1]) -Value $matches[2]
    }
}

/*[nvim-treesitter/install/c]: Compiling parser [nvim-treesitter/install/json] error: Error during "tree-sitter build": [31mError:[0m Failed to compile parser Caused by: Parser compilation failed. 
 * Stdout: Stderr: C:\Strawberry\c\bin\ld.exe: cannot open output file \\?\C:\Users\Streaming\AppData\Local\Temp\nvim\tree-sitter-json\parser.so: 
 * Invalid argument clang: error: linker command failed with exit code 1 (use -v to see invocation)
 */

# solution was just removing Strawberry paths from environmental variables, but even adding llvm above my strawberry paths didn't help. Don't like being so destructive, maybe there's a way to check what linker nvim is set to, even if echo $CC returns clang

# 3️⃣ Set environment variables for Tree-sitter
$env:CC = "clang"
$env:CXX = "clang++"
$env:TREE_SITTER_C_COMPILER = "clang"

# 4️⃣ Add LLVM to PATH (for this session)
$env:PATH = "$llvmPath;$env:PATH"

# 5️⃣ Verify Clang can compile a test C file
$testC = @"
#include <stdio.h>
int main() { printf("Hello, Clang!\n"); return 0; }
"@
$testFile = "$env:TEMP\test.c"
$exeFile  = "$env:TEMP\test.exe"
Set-Content -Path $testFile -Value $testC
clang "$testFile" -o "$exeFile"
if (Test-Path "$exeFile") {
    Write-Host "Clang can compile programs!"
} else {
    Write-Host "Clang test failed!"
}

# 6️⃣ Launch Neovim in this environment
#    Parsers will now build correctly
nvim
