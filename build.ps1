
if ($args[0] -eq "--first") {
  Write-Host -ForegroundColor "blue" "Configuring for first build..."

  # Remove build directory if it already exists
  if (Test-Path -Path "build" -PathType Container) {
    Remove-Item build -Recurse
  }

  $null = New-Item -ItemType directory -Path build
  Set-Location build
  Set-Location ..

  if (Test-Path -Path "temp" -PathType Container) {
    Remove-Item temp -Recurse
  }

  $null = New-Item -ItemType directory -Path temp
  Set-Location temp

  Write-Host -ForegroundColor "blue" "Downloading SDL2..."
  Invoke-WebRequest "https://github.com/libsdl-org/SDL/releases/download/release-2.30.11/SDL2-devel-2.30.11-VC.zip" -o "sdl2.zip"

  Write-Host -ForegroundColor "blue" "Extracting SDL2..."
  Expand-Archive -Path "sdl2.zip" -DestinationPath "SDL2"

  Write-Host -ForegroundColor "blue" "Downloading SDL2_ttf..."
  Invoke-WebRequest "https://github.com/libsdl-org/SDL_ttf/releases/download/release-2.24.0/SDL2_ttf-devel-2.24.0-VC.zip" -o "sdl_ttf.zip"
  
  Write-Host -ForegroundColor "blue" "Extracting SDL2_ttf..."
  Expand-Archive -Path "sdl_ttf.zip" -DestinationPath "SDL_ttf"

  Move-Item "SDL2/SDL2-2.30.11/lib/x64" "SDL2_2"
  Remove-Item sdl2.zip
  Remove-Item SDL2 -Recurse
  Rename-Item SDL2_2 SDL2

  Move-Item "SDL_ttf/SDL2_ttf-2.24.0/lib/x64" "SDL_ttf_2"
  Remove-Item sdl_ttf.zip
  Remove-Item SDL_ttf -Recurse
  Rename-Item SDL_ttf_2 SDL_ttf

  Set-Location ..
  Move-Item temp\SDL2 build

  Move-Item build\SDL2\* build
  Remove-Item build\SDL2

  Move-Item temp\SDL_ttf build
  Move-Item build\SDL_ttf\* build
  Remove-Item build\SDL_ttf
  
  Remove-Item temp -Recurse
}

# Now we can build
Write-Host -ForegroundColor "blue" "Assembling..."
nasm -fwin64 sedit\sedit.asm -o build\sedit.obj

Write-Host -ForegroundColor "blue" "Linking..."
$null = GoLink build\sedit.obj /console build\SDL2.dll msvcrt.dll kernel32.dll

Write-Host -ForegroundColor "green" "Build finished!"
