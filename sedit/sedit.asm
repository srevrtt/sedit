
section .data

renderer dq 1
window dq 1
event db 56
windowFailedText db "An error occurred. Failed to create an SDL2 window.", 0xa, 0
sdlInitFailedText db "An error occurred. Failed to initialize SDL2.", 0xa, 0
windowTitle db "SEdit | Debug Edition", 0
errorFormat db "%s", 0xa, 0
hello db "HEllo world!", 0xa, 0

section .bss

currentRect resd 4
currentRectColor resd 3

section .text
global Start

extern SDL_Init
extern SDL_CreateWindow
extern SDL_GetErrors
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

  ; SDL_SetRenderDrawColor(renderer, 20, 10, 10)
  mov rcx, [renderer]
  mov edx, 20
  mov r8d, 50
  mov r9d, 10
  call SDL_SetRenderDrawColor

  ; SDL_RenderClear(renderer)
  mov rcx, [renderer]
  call SDL_RenderClear

  ; SDL_RenderPresent(renderer)
  mov rcx, [renderer]
  call SDL_RenderPresent

  add rsp, 48
  jmp appLoop

sdlInitFailed:
  mov rcx, sdlInitFailedText
  call printf
  ret

createSDLWindowFailed:
  mov rcx, windowFailedText
  call printf
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

  ; SDL_SetRenderDrawColor(renderer, 20, 10, 10)
  mov rcx, [renderer]
  mov edx, 20
  mov r8d, 50
  mov r9d, 10
  call SDL_SetRenderDrawColor

  ; SDL_RenderClear(renderer)
  mov rcx, [renderer]
  call SDL_RenderClear

  ; rendering

  ; set rectangle color
  mov dword [currentRectColor+0], 200
  mov dword [currentRectColor+4], 0
  mov dword [currentRectColor+8], 200

  mov dword [currentRect+0], 10 ; x
  mov dword [currentRect+4], 10 ; y
  mov dword [currentRect+8], 100 ; w
  mov dword [currentRect+12], 100 ; h
  call drawRect

  mov dword [currentRectColor+8], 0
  mov dword [currentRect+0], 300 ; x
  mov dword [currentRect+4], 300 ; y
  mov dword [currentRect+8], 200 ; w
  mov dword [currentRect+12], 200 ; h
  call drawRect

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
