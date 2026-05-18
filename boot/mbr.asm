section mbr vstart=0x7c00
;; 初始化
    mov ax, cs
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov sp, 0x7c00

;; 清屏
    mov ax, 0x3
    int 0x10

;; 打印开机第一个提示语
    mov si, msg
    call print

;; 读取后续扇区
    mov eax, 0x1
    mov bx, 0x500
    mov cx, 4
    call read_disk

;; 跳转到 loader
    jmp 0x500

;; 打印函数
print:
    mov ah, 0x0e

.next:
    lodsb
    test al, al
    jz .done
    int 0x10
    jmp .next

.done:
    ret

;; 磁盘操作函数
read_disk:
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

;; 数据定义
    msg db "welcome to mikuOS world...", 13, 10, 0

    times 510 - ($ - $$) db 0
    db 0x55, 0xaa
