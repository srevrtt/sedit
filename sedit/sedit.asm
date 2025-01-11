
section .data

renderer dq 1
window dq 1
event db 56
windowFailedText db "An error occurred. Failed to create an SDL2 window.", 0xa, 0
sdlInitFailedText db "An error occurred. Failed to initialize SDL2.", 0xa, 0
windowTitle db "SEdit | Debug Edition", 0
errorFormat db "%s", 0xa, 0
hello db "HEllo world!", 0xa, 0

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
  mov r8d, 10
  mov r9d, 10
  call SDL_SetRenderDrawColor

  ; SDL_RenderClear(renderer)
  mov rcx, [renderer]
  call SDL_RenderClear

  ; SDL_RenderPresent(renderer)
  mov rcx, [renderer]
  call SDL_RenderPresent

  add rsp, 48

  jmp gameLoop

sdlInitFailed:
  mov rcx, sdlInitFailedText
  call printf
  ret

createSDLWindowFailed:
  mov rcx, windowFailedText
  call printf
  ret

gameLoop:
  sdlPoll:
    ; mov rcx, hello
    ; call printf

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
  mov r8d, 10
  mov r9d, 10
  call SDL_SetRenderDrawColor

  ; SDL_RenderClear(renderer)
  mov rcx, [renderer]
  call SDL_RenderClear

  ; SDL_RenderPresent(renderer)
  mov rcx, [renderer]
  call SDL_RenderPresent

  jmp gameLoop

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
