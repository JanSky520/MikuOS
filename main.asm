%include "boot.inc"

section mbr vstart=0x7c00
    xor ax, ax
    mov ds, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7C00
    mov ax, 0xb800
    mov gs, ax

    mov ax, 3
    int 0x10

    mov si, msg
    call print
    
    mov eax, LOADER_START_SECTOR
    mov bx, LOADER_BASE_ADDR
    mov cx, 4
    call read_disk_16

    jmp LOADER_BASE_ADDR

print:
    mov ah, 0x0e
.next:
    mov al, [si]
    cmp al, 0
    jz .done
    int 0x10
    inc si
    jmp .next
.done:
    ret
    
read_disk_16:
    mov esi, eax
    mov di, cx
    
    mov dx, 0x1f2
    mov al, cl
    out dx, al

    mov dx, 0x1f3
    mov eax, esi
    out dx, al

    mov dx, 0x1f4
    shr eax, 8
    out dx, al

    mov dx, 0x1f5
    shr eax, 8
    out dx, al

    mov dx, 0x1f6
    shr eax, 8
    and al, 0x0f
    or al, 0xe0
    out dx, al

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

.ready_16:
    nop
    in al, dx
    and al, 0x88
    cmp al, 0x08
    jnz .ready_16

    mov ax, di
    mov dx, 256
    mul dx
    mov cx, ax
    mov dx, 0x1f0
.read_16:
    in ax, dx
    mov [bx], ax
    add bx, 2
    loop .read_16

    ret

    msg db "welcome to mikuOS!!!", 10, 13, 0
    
    times 510 - ($ - $$) db 0
    db 0x55, 0xaa
