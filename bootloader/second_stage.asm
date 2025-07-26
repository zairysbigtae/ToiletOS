use16
org 0x0000 

_start:
    mov ax, 0x1000      ; match segment used in bootloader.asm when jumping to 0x1000:0x0000
    mov ds, ax          ; DS:SI is now correct, since DS = 0x1000

    mov si, message
    call print_string

    cli
    hlt

message db "Entered second stage of bootloader. Sara is supreme frfr\n", 0 

include "libs/print.inc"
