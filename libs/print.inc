use16

print_string:
    mov ah, 0x0e ; BIOS teletype

.print_next_char:
    lodsb
    or al, al
    jz .done ; if theres '\0'? hang

    cmp al, 92 ; check if its '\'
    je .is_control_char

    ; mov ah, 0x0e ; shift out

    int 0x10
    jmp .print_next_char ; loop, to print next char

.is_control_char:
    lodsb ; next char after '\'

    cmp al, 110 ; check if its 'n'
    je .newline

    cmp al, 114 ; check if its 'r'
    je .carriage_return

    int 0x10
    jmp .print_next_char

.carriage_return:
    ; carriage return 
    mov ah, 0x0e ; shift out
    mov al, 13 ; cr
    int 0x10

    jmp .print_next_char

.newline:
    ; carriage return
    ; cuz if you comment this code out, youd see a big ass space in the bootloader screen
    mov al, 13 ; '\r'
    int 0x10
    mov al, 10 ; '\n'
    int 0x10
    jmp .print_next_char

.done:
    ret

print_char:
    mov ah, 0x0e
    int 0x10

    jmp .done

.done:
    ret
