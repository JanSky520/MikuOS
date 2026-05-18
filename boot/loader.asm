section loader vstart=0x500
    cli

;; 打印 loader 提示语
    mov si, loader_msg
    call print

;; 进行内存检测
    call detect_memory

;; 打开 A20
    in al, 0x92
    or al, 00000010b
    out 0x92, al

;; 加载 gdt
    lgdt [gdt_ptr]

;; 值位 CR0 寄存器
    mov eax, cr0
    or eax, 1
    mov cr0, eax

;; 刷新流水线
    jmp dword SELECTOR_CODE:p_mode_start

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

;; 内存检测函数
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
    mov si, mem_msg
    call print

    ret

;; 错误函数
error:
    mov si, error_msg
    call print
    hlt
    jmp $
    error_msg db "loading error!!!", 13, 10, 0

;; 数据定义
    gdt_base dd 0x00000000, 0x00000000                ;; 第 0 个描述符必须是 NULL
    code_desc dd 0x0000ffff, DESC_CODE_HIGH4          ;; 代码段描述符
    data_stack_desc dd 0x0000ffff, DESC_DATA_HIGH4    ;; 数据段与栈段描述符
    video_desc dd 0x80000007, DESC_VIDEO_HIGH4        ;; 视频段描述符

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

    loader_msg    db "loading system...", 13, 10, 0
    mem_msg       db "detect memory success...", 13, 10, 10, 0

    DESC_G_4K         equ 1000_0000_0000_0000_0000_0000b    ;; 设置段界限为 4 KB
    DESC_D_32         equ 100_0000_0000_0000_0000_0000b     ;; 设置代码段/数据段的有效地址（段内偏移地址）及操作数大小为 32 位，而非 16 位
    DESC_L_4K         equ 00_0000_0000_0000_0000_0000b      ;; 64 位代码段标记位，我们现在是在编写 32 位操作系统，此处标记为 0 便可
    DESC_AVL          equ 0_0000_0000_0000_0000_0000b       ;; 取决于开发者如何使用这个位，从硬件的角度来看，AVL 位没有任何特定的功能或意义，它的使用完全由软件决定
    DESC_LIMIT_CODE2  equ 1111_0000_0000_0000_0000b         ;; 定义代码段要用的段描述符高 32 位中 16~19 段界限为全 1
    DESC_LIMIT_DATA2  equ DESC_LIMIT_CODE2                  ;; 定义数据段要用的段描述符高 32 位中 16~19 段界限为全 1
    DESC_LIMIT_VIDEO2 equ 0000_0000_0000_0000_0000b         ;; 定义我们要操作显存时对应的段描述符的高 32 位中 16~19 段界限为全 0
    DESC_P            equ 1000_0000_0000_0000b              ;; 定义了段描述符中的 P 标志位，表示该段描述符指向的段是否在内存中
    DESC_DPL_0        equ 000_0000_0000_0000b               ;; 定义DPL为 0 的字段
    DESC_DPL_1        equ 010_0000_0000_0000b               ;; 定义DPL为 1 的字段
    DESC_DPL_2        equ 100_0000_0000_0000b               ;; 定义DPL为 2 的字段
    DESC_DPL_3        equ 110_0000_0000_0000b               ;; 定义DPL为 3 的字段
    DESC_S_CODE       equ 1_0000_0000_0000b                 ;; 无论代码段还是数据段，对于 CPU 来说都是非系统段，所以将 S 位置为 1
    DESC_S_DATA       equ DESC_S_CODE                       ;; 无论代码段还是数据段，对于 CPU 来说都是非系统段，所以将 S 位置为 1
    DESC_S_SYS        equ 0_0000_0000_0000b                 ;; 将段描述符的 S 位置为 0，表示系统段
    DESC_TYPE_CODE    equ 1000_0000_0000b                   ;; x=1 c=0 r=0 a=0 代码段是可执行的,非依从的,不可读的,已访问位 a 清 0
    DESC_TYPE_DATA    equ 0010_0000_0000b                   ;; x=0 e=0 w=1 a=0 数据段是不可执行的,向上扩展的,可写的,已访问位 a 清 0

    DESC_CODE_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L_4K + DESC_AVL + DESC_LIMIT_CODE2 + DESC_P + DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00
    DESC_DATA_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L_4K + DESC_AVL + DESC_LIMIT_DATA2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00
    DESC_VIDEO_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L_4K + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0b

    RPL0   equ 00b     ;; 定义选择字的 RPL 为 0
    RPL1   equ 01b     ;; 定义选择字的 RPL 为 1
    RPL2   equ 10b     ;; 定义选择字的 RPL 为 2
    RPL3   equ 11b     ;; 定义选择字的 RPL 为 3
    TI_GDT equ 000b    ;; 定义段选择子请求的段描述符是在 GDT 中
    TI_LDT equ 100b    ;; 定义段选择子请求的段描述符是在 LDT 中

[bits 32]
;; 进入保护模式
p_mode_start:
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov esp, 0x7C00

    mov ax, SELECTOR_VIDEO
    mov gs, ax

;; 读取后续扇区
    mov eax, 0x5
    mov ebx, KERNEL_BIN_BASE_ADDR
    mov ecx, 200
    call read_disk

;; 开启分页
    call setup_page

    sgdt [gdt_ptr]

    mov ebx, [gdt_ptr + 2]
    or dword [ebx + 0x18 + 4], 0xc0000000

    add dword [gdt_ptr + 2], 0xc0000000

    add esp, 0xc0000000

    mov eax, PAGE_DIR_TABLE_POS
    mov cr3, eax
    mov eax, cr0
    or eax, 0x80000000
    mov cr0, eax

    lgdt [gdt_ptr]

    mov byte [gs:480], 'p'
    mov byte [gs:482], 'a'
    mov byte [gs:484], 'g'
    mov byte [gs:486], 'e'
    mov byte [gs:488], ' '
    mov byte [gs:490], 'o'
    mov byte [gs:492], 'p'
    mov byte [gs:494], 'e'
    mov byte [gs:496], 'n'

    call kernel_init
    mov esp, 0xc009f000
    jmp 0xc0001500

;; 操作磁盘函数
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
    mov [ebx], ax
    add ebx, 2
    loop .read_16

    ret

;; 分页函数
setup_page:
    mov ecx, 4096
    mov esi, 0

.clear_page_dir:
    mov byte [PAGE_DIR_TABLE_POS + esi], 0
    inc esi
    loop .clear_page_dir

.create_pde:
    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x1000
    mov ebx, eax

    or eax, PG_US_U | PG_RW_W | PG_P
    mov [PAGE_DIR_TABLE_POS + 0x0], eax
    mov [PAGE_DIR_TABLE_POS + 0xc00], eax
    sub eax, 0x1000
    mov [PAGE_DIR_TABLE_POS + 4092], eax

    mov ecx, 256
    mov esi, 0
    mov edx, PG_US_U | PG_RW_W | PG_P

.create_pte:
    mov [ebx+esi*4],edx
    add edx,4096
    inc esi
    loop .create_pte

    mov eax, PAGE_DIR_TABLE_POS
    add eax, 0x2000
    or eax, PG_US_U | PG_RW_W | PG_P
    mov ebx, PAGE_DIR_TABLE_POS
    mov ecx, 254
    mov esi, 769

    .create_kernel_pde:
    mov [ebx+esi*4], eax
    inc esi
    add eax, 0x1000
    loop .create_kernel_pde

    ret

kernel_init:
    xor eax, eax                                        ;清空eax
    xor ebx, ebx		                                ;清空ebx, ebx记录程序头表地址
    xor ecx, ecx		                                ;清空ecx, cx记录程序头表中的program header数量
    xor edx, edx		                                ;清空edx, dx 记录program header尺寸

    mov dx, [KERNEL_BIN_BASE_ADDR + 42]	                ; 偏移文件42字节处的属性是e_phentsize,表示program header table中每个program header大小
    mov ebx, [KERNEL_BIN_BASE_ADDR + 28]                ; 偏移文件开始部分28字节的地方是e_phoff,表示program header table的偏移，ebx中是第1 个program header在文件中的偏移量
					                                    ; 其实该值是0x34,不过还是谨慎一点，这里来读取实际值
    add ebx, KERNEL_BIN_BASE_ADDR                       ; 现在ebx中存着第一个program header的内存地址
    mov cx, [KERNEL_BIN_BASE_ADDR + 44]                 ; 偏移文件开始部分44字节的地方是e_phnum,表示有几个program header
.each_segment:
    cmp byte [ebx + 0], PT_NULL		                    ; 若p_type等于 PT_NULL,说明此program header未使用。
    je .PTNULL

                                                        ;为函数memcpy压入参数,参数是从右往左依然压入.函数原型类似于 memcpy(dst,src,size)
    push dword [ebx + 16]		                        ; program header中偏移16字节的地方是p_filesz,压入函数memcpy的第三个参数:size
    mov eax, [ebx + 4]			                        ; 距程序头偏移量为4字节的位置是p_offset，该值是本program header 所表示的段相对于文件的偏移
    add eax, KERNEL_BIN_BASE_ADDR	                    ; 加上kernel.bin被加载到的物理地址,eax为该段的物理地址
    push eax				                            ; 压入函数memcpy的第二个参数:源地址
    push dword [ebx + 8]			                    ; 压入函数memcpy的第一个参数:目的地址,偏移程序头8字节的位置是p_vaddr，这就是目的地址
    call mem_cpy				                        ; 调用mem_cpy完成段复制
    add esp,12				                            ; 清理栈中压入的三个参数
.PTNULL:
   add ebx, edx				                            ; edx为program header大小,即e_phentsize,在此ebx指向下一个program header 
   loop .each_segment
   ret

;; 内存拷贝函数
mem_cpy:		      
    cld                    ;; 将FLAG的方向标志位DF清零，rep在执行循环时候si，di就会加1
    push ebp               ;; 这两句指令是在进行栈框架构建
    mov ebp, esp
    push ecx               ;; rep指令用到了ecx，但ecx对于外层段的循环还有用，故先入栈备份
    mov edi, [ebp + 8]	   ;; dst，edi与esi作为偏移，没有指定段寄存器的话，默认是ss寄存器进行配合
    mov esi, [ebp + 12]	   ;; src
    mov ecx, [ebp + 16]    ;; size
    rep movsb		   ;; 逐字节拷贝

    pop ecx		
    pop ebp

    ret

;; 数据定义
    PAGE_DIR_TABLE_POS equ 0x100000

    PG_P    equ 1b
    PG_RW_R equ 00b
    PG_RW_W equ 10b
    PG_US_S equ 000b
    PG_US_U equ 100b

    KERNEL_BIN_BASE_ADDR equ 0x70000

    PT_NULL equ 0
