
section .data

renderer dq 1
window dq 1
event db 56
windowFailedText db "An error occurred. Failed to create an SDL2 window.", 0xa, 0
sdlInitFailedText db "An error occurred. Failed to initialize SDL2.", 0xa, 0
ttfInitFailedText db "An error occurred. Failed to initialize SDL2_ttf.", 0xa, 0
windowTitle db "SEdit | Debug Edition", 0
errorFormat db "%s", 0xa, 0
hello db "HEllo world!", 0xa, 0
fontFilePath db "..\resources\fonts\sourcecodepro\SourceCodePro-Regular.ttf"

section .bss

currentRect resd 4
currentRectColor resd 3
codeFont resq 1
fontColor resd 1

section .text

global Start

extern SDL_Init
extern TTF_Init
extern SDL_CreateWindow
extern SDL_GetError
extern TTF_OpenFont
extern TTF_RenderText_Blended
extern SDL_CreateTextureFromSurface
extern SDL_FreeSurface
extern SDL_CreateRenderer
extern SDL_SetRenderDrawColor
extern SDL_RenderClear
extern SDL_RenderPresent
extern SDL_PollEvent
extern SDL_DestroyRenderer
extern SDL_DestroyWindow
extern SDL_RenderFillRect
extern SDL_Quit
extern ExitProcess
extern printf

createWindow:
  mov ecx, 0x20
  call SDL_Init
  test eax, eax
  js sdlInitFailed

  call TTF_Init
  js ttfInitFailed

  sub rsp, 48

  lea rcx, [windowTitle]
  mov edx, 0x2FFF0000 ; SDL_WINDOWPOS_CENTERED
  mov r8d, 0x2FFF0000 ; SDL_WINDOWPOS_CENTERED
  mov r9d, 1280 ; width
  mov qword [esp+32], 720
  mov dword [esp+40], 4

  call SDL_CreateWindow
  mov [window], rax

  test rax, rax
  jz createSDLWindowFailed

  ; create renderer
  mov rcx, [window] ; SDL_WINDOW
  mov edx, -1 ; index
  mov r8, 2 ; SDL_RENDERER_ACCELERATED
  call SDL_CreateRenderer
  mov [renderer], rax

  ; SDL_SetRenderDrawColor(renderer, 0, 0, 0)
  mov rcx, [renderer]
  mov edx, 0
  mov r8d, 0
  mov r9d, 0
  call SDL_SetRenderDrawColor

  ; SDL_RenderClear(renderer)
  mov rcx, [renderer]
  call SDL_RenderClear

  ; SDL_RenderPresent(renderer)
  mov rcx, [renderer]
  call SDL_RenderPresent

  add rsp, 48

  call initApp
  jmp appLoop

sdlInitFailed:
  mov rcx, sdlInitFailedText
  call printf
  ret

ttfInitFailed:
  mov rcx, ttfInitFailedText
  call printf
  ret

createSDLWindowFailed:
  mov rcx, windowFailedText
  call printf
  ret

initFonts:
  ; TTF_OpenFont(filepath, 16 [size]);
  mov rcx, fontFilePath
  mov edx, 16
  call TTF_OpenFont
  mov [codeFont], rax
  ret

renderText:
  ; set to white for now
  ; FIXME
  ; SDL_Color {255, 255, 255}
  mov dword [fontColor+0], 255
  mov dword [fontColor+4], 255
  mov dword [fontColor+8], 255

  ; the font is already in rcx because of the callee
  ; the text is already in rdx
  ; TTF_RenderText_Blended(font, text, fontColor)
  mov rcx, codeFont
  mov rdx, [hello]
  mov r8d, fontColor
  call TTF_RenderText_Blended
  mov rdi, [rax] ; save the SDL_Surface to free it

  ; convert SDL_Surface into SDL_Texture
  ; SDL_CreateTextureFromSurface(renderer, rax [surface])
  mov rcx, [renderer]
  mov rdx, [rax]
  call SDL_CreateTextureFromSurface

  ; free the surface
  ; SDL_FreeSurface(&rdi [surface])
  mov rcx, [rdi]
  call SDL_FreeSurface

  ret

drawRect:
  ; SDL_SetRenderDrawColor(renderer, 255, 255, 255)
  mov rcx, [renderer]
  mov edx, [currentRectColor+0]
  mov r8d, [currentRectColor+4]
  mov r9d, [currentRectColor+8]
  call SDL_SetRenderDrawColor

  ; SDL_RenderFillRect(renderer, &rect)
  mov rcx, [renderer]
  lea rdx, [currentRect]
  call SDL_RenderFillRect

  ret

initApp:
  call initFonts
  ret

appLoop:
  sdlPoll:
    ; SDL_PollEvent(&event)
    lea rcx, event
    call SDL_PollEvent
    mov esi, eax

    mov eax, [event]
    cmp eax, 256 ; [event+0] = event.type, 256 = SDL_QUIT
    je quitWindow

    cmp esi, 1
    je sdlPoll

  ; clear the screen

  ; SDL_SetRenderDrawColor(renderer, 0, 0, 0)
  mov rcx, [renderer]
  mov edx, 0
  mov r8d, 0
  mov r9d, 0
  call SDL_SetRenderDrawColor

  ; SDL_RenderClear(renderer)
  mov rcx, [renderer]
  call SDL_RenderClear

  ; rendering

  ; set rectangle color
  mov dword [currentRectColor+0], 200
  mov dword [currentRectColor+4], 200
  mov dword [currentRectColor+8], 200

  mov dword [currentRect+0], 10 ; x
  mov dword [currentRect+4], 10 ; y
  mov dword [currentRect+8], 100 ; w
  mov dword [currentRect+12], 100 ; h
  call drawRect

  ; render some text
  mov rcx, sdlInitFailedText
  call printf
  mov rcx, [codeFont]
  mov rdx, [hello]
  call renderText

  ; SDL_RenderPresent(renderer)
  mov rcx, [renderer]
  call SDL_RenderPresent

  jmp appLoop

quitWindow:
  ; SDL_DestroyRenderer(renderer)
  mov rcx, [renderer]
  call SDL_DestroyRenderer

  ; SDL_DestroyWindow(window)
  mov rcx, [window]
  call SDL_DestroyWindow

  ; SDL_Quit()
  call SDL_Quit
  jmp exitProgram

exitProgram:
  mov rcx, 0 ; exit code
  call ExitProcess

Start:
  call createWindow
