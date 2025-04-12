%include "boot.inc"

section loader vstart=LOADER_BASE_ADDR
    LOADER_STACK_TOP equ LOADER_BASE_ADDR

    cli
    
    in al, 0x92
    or al, 00000010b
    out 0x92, al

    lgdt [gdt_ptr]

    mov eax, cr0
    or eax, 1
    mov cr0, eax

    jmp SELECTOR_CODE:p_mode_start
    
bits 32
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP

    mov ax, SELECTOR_VIDEO
    mov gs, ax
    mov byte [gs:160], '9'

    jmp $

bits 16    
gdt_base:
    dd 0x00000000
    dd 0x00000000
code_desc:
    dd 0x0000ffff
    dd DESC_CODE_HIGH4
data_stack_desc:
    dd 0x0000ffff
    dd DESC_DATA_HIGH4
video_desc:
    dd 0x80000007
    dd DESC_VIDEO_HIGH4

    GDT_SIZE  equ $ - gdt_base
    GDT_LIMIT equ GDT_SIZE - 1
    times 50 dq 0

    SELECTOR_CODE  equ (0x0001 << 3) + TI_GDT + RPL0
    SELECTOR_DATA  equ (0x0002 << 3) + TI_GDT + RPL0
    SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

    gdt_ptr dw GDT_LIMIT
            dd gdt_base
