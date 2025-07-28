use16
org 0x0000 ; This tells the assembler that the code thinks it starts at 0x0000:0x0000
           ; this is fine if the second stage is loaded at 0x1000:0x0000, 
           ; because you compensate MANUALLY with the segment.
jmp _start

include "libs/print.inc"

_start:
    ; mov ah, 0x0e
    ; mov al, '!'
    ; int 0x10
    mov al, '!'
    call print_char

    mov ax, cs      ; match segment used in bootloader.asm when jumping to 0x1000:0x0000
    mov ds, ax          ; DS:SI is now correct, since DS = 0x1000

    mov si, message
    call print_string

    call get_memory_map

    ; pretty much freezes the cpu
    ; but ofc, we will remove this LATER
    ; cli
    ; hlt

get_memory_map:
    mov si, loading_mem_map_msg
    call print_string

    mov ax, 0x9000
    mov es, ax
    xor di, di

    mov di, mem_map_buffer
    xor ebx, ebx ; continuation value???

.next:
    mov si, still_loading_mem_map_msg
    call print_string
    ; 0xe820 is used for reporting the memory map to the OS 
    ; or the bootloader (which is what we working on rn LMFAO)
    ; and its accessed by `int 15h` by setting ax register to 0xe820
    ;
    ; ASCII CODE FOR "SMAP" => 0x534D4150
    xor eax, eax
    xor ecx, ecx 

    mov eax, 0xe820
    mov edx, 0x534D4150 ; "SMAP"
    mov ecx, 24 ; size of buffer

    ; Interrupt Number: INT 15h
    ; Function Selector: The AH register is used to select a specific function within the interrupt. 
    int 0x15

    jc .done  ; carrying flag? done, exit, no questiosn
    cmp eax, 0x534D4150 ; "SMAP"
    jne .done ; BIOS did not return "SMAP"

    mov si, got_one_msg
    call print_string

    add di, 24  ; next entry
    test ebx, ebx
    jnz .next

.done:
    mov si, got_mem_map_msg
    call print_string

    jmp .done
    ; ret

mem_map_buffer:
    times 1024 db 0

message db "Entered second stage of bootloader. Sara is supreme frfr\n", 0 
got_mem_map_msg db "Successfully got the memory map\n", 0
loading_mem_map_msg db "Getting memory map..\n", 0
still_loading_mem_map_msg db "Still getting memory map..\n", 0

got_one_msg db "Got memory map\n", 0

excl_msg db "!\n", 0
