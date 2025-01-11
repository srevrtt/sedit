
if ($args[0] -eq "--first") {
  Write-Host -ForegroundColor "blue" "Configuring for first build..."

  # Remove build directory if it already exists
  if (Test-Path -Path "build" -PathType Container) {
    Remove-Item build -Recurse
  }

  New-Item -ItemType directory -Path build
  Set-Location build
  Set-Location ..

  if (Test-Path -Path "temp" -PathType Container) {
    Remove-Item temp -Recurse
  }

  New-Item -ItemType directory -Path temp
  Set-Location temp

  Write-Host -ForegroundColor "blue" "Downloading SDL2..."
  Invoke-WebRequest "https://github.com/libsdl-org/SDL/releases/download/release-2.30.11/SDL2-devel-2.30.11-VC.zip" -o "sdl2.zip"

  Write-Host -ForegroundColor "blue" "Extracting SDL2..."
  Expand-Archive -Path "sdl2.zip" -DestinationPath "SDL2"

  Move-Item "SDL2/SDL2-2.30.11/lib/x64" "SDL2_2"
  Remove-Item sdl2.zip
  Remove-Item SDL2 -Recurse
  Rename-Item SDL2_2 SDL2

  Set-Location ..
  Move-Item temp\SDL2 build
  Remove-Item temp

  Move-Item build\SDL2\* build
  Remove-Item build\SDL2
}

# Now we can build
Write-Host -ForegroundColor "blue" "Building project..."
nasm -fwin64 sedit\sedit.asm -o build\sedit.obj

Write-Host -ForegroundColor "blue" "Linking..."
GoLink build\sedit.obj /console build\SDL2.dll msvcrt.dll kernel32.dll

Write-Host -ForegroundColor "green" "Build finished!"
