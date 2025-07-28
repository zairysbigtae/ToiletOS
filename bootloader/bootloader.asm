use16
org 0x7C00 ; BIOS loads us here
jmp _start

include "libs/print.inc"

_start:
    cli
    xor ax, ax
    mov ds, ax
    mov es, ax

    mov ah, 0x02     ; BIOS function: read sector
    mov al, 0x01     ; read 1 sector
    mov ch, 0x00     ; cylinder
    mov cl, 0x02     ; sector (must start from 1, so sector 2 is the next one)
    mov dh, 0x00     ; head
    mov dl, 0x80     ; drive (0x00 = floppy, 0x80 = hard disk)
    mov bx, 0x0000   ; offset

    push ax ; save ax
    mov ax, 0x1000
    mov es, ax      ; Segment -> 0x1000:0000 = 0x10000 physical address
    pop ax ; load ax back

    ; just to be safe
    ; clear carry flag
    ; clc

    int 0x13 ; disk interrupt, reads into ES:BX
    jc .disk_error ; if there carry set'd, then error

    ; intro LOL
    mov si, message
    call print_string

    mov si, boot_msg
    call print_string
    ; jump to the loaded second-stage bootloader
    jmp 0x1000:0000

    ; how to get physical address
    ; physical address = (segment * 0x10) + offset
    ; mov ax, 0x800
    ; mov es, ax
    ; mov bx, 0x0000
    ; load sector into ES:BX

    mov si, jmp_boot_msg
    call print_string

    ; call get_key

.disk_error:
    mov si, disk_read_error_msg
    call print_string
    hlt

get_key:
    call .input_loop

.input_loop:
    mov ah, 0x00 ; wait for key
    int 0x16
    ; call .input_finished

    mov ah, 0x0e ;  teletype mode
    int 0x10 ; print

    cmp al, 0x0d ; or 13 in decimal, this is a carriage return btw but enter and cr should be just the same-
    je .input_finished

    jmp .input_loop

.input_finished:
    ; == output part == pushing ax and load it,  cuz we need to modify it a bit for newline
    push ax ; save ax
    call print_string.newline

    pop ax ; load ax

    int 0x10


message db "HELLO WORLD!\npurrs on sara\n", 0 ; 0 = null termination, 10 = newline
disk_read_error_msg db "Disk read error!\n", 0

boot_msg db "Stage 1 loaded. Loading stage 2...\n", 0
jmp_boot_msg db "Jumped to the location\n", 0

times 510 - ($ - $$) db 0
dw 0xAA55 ; boot signature
