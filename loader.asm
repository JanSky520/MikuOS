%include "boot.inc"

extern print

section loader vstart=LOADER_BASE_ADDR
    LOADER_STACK_TOP equ LOADER_BASE_ADDR

    cli

    mov si, msg
    call print                      ;打印loader

    call detect_memory              ;内存检测
    
;---准备进入保护模式---------------------------------------------
    in al, 0x92
    or al, 00000010b
    out 0x92, al

    lgdt [gdt_ptr]
    
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    
    jmp SELECTOR_CODE:p_mode_start

;---进入保护模式成功-----------------------------------------------
[bits 32]
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP

    mov ax, SELECTOR_VIDEO
    mov gs, ax
    mov byte [gs:480], 'p'
    mov byte [gs:482], 'a'
    mov byte [gs:484], 'g'
    mov byte [gs:486], 'e'
    mov byte [gs:488], '.'
    mov byte [gs:490], '.'
    mov byte [gs:492], '.'
    
;---开始先页目录占用空间逐字清零----------------------------------
setup_page:
    mov ecx, 4096
    mov esi, 0
.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

;---开始创建页目录（PDE）-----------------------------------------
.create_pde:
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x1000
    mov ebx, eax

    or eax, PG_US_U | PG_RW_W | PG_P
    mov [PAGE_DIR_TABLE_POS + 0x0], eax
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax

    jmp $

;---可供使用的函数------------------------------------------------
[bits 16]
print:
    mov ah, 0x0e
print_next:
    mov al, [si]
    cmp al, 0
    jz print_done
    int 0x10
    inc si
    jmp print_next
print_done:
    ret

detect_memory:
    xor ebx, ebx
    mov ax, 0
    mov es, ax
    mov di, ards_buf
    mov edx, 0x534d4150    
.detect_next:
    mov eax, 0xe820
    mov ecx, 20
    int 0x15
    jc error
    add di, cx
    inc word [ards_count]
    cmp ebx, 0
    jnz .detect_next
    mov si, detect
    call print
    ret

error:
    mov si, error_msg
    call print
    hlt
    jmp $
    error_msg db "loading error!!!", 13, 10, 0

;---各种数据的定义------------------------------------------------
    gdt_base dd 0x00000000, 0x00000000
    code_desc dd 0x0000ffff, DESC_CODE_HIGH4
    data_stack_desc dd 0x0000ffff, DESC_DATA_HIGH4
    video_desc dd 0x80000007, DESC_VIDEO_HIGH4

    GDT_SIZE  equ $ - gdt_base
    GDT_LIMIT equ GDT_SIZE - 1
    times 60 dq 0

    total_mem_bytes dd 0

    SELECTOR_CODE  equ (0x0001 << 3) + TI_GDT + RPL0
    SELECTOR_DATA  equ (0x0002 << 3) + TI_GDT + RPL0
    SELECTOR_VIDEO equ (0x0003 << 3) + TI_GDT + RPL0

    gdt_ptr dw GDT_LIMIT
            dd gdt_base

    ards_buf times 244 db 0
    ards_count dw 0

    msg    db "loading system...", 13, 10, 0
    detect db "detect memory success...", 13, 10, 0
