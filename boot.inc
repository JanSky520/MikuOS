;---GDT相关属性-----------------------------------------------------
LOADER_BASE_ADDR    equ 0x900
LOADER_START_SECTOR equ 0x2

DESC_G_4K         equ 1000_0000_0000_0000_0000_0000b
DESC_D_32         equ 100_0000_0000_0000_0000_0000b
DESC_L_4K         equ 00_0000_0000_0000_0000_0000b
DESC_AVL          equ 0_0000_0000_0000_0000_0000b
DESC_LIMIT_CODE2  equ 1111_0000_0000_0000_0000b
DESC_LIMIT_DATA2  equ DESC_LIMIT_CODE2
DESC_LIMIT_VIDEO2 equ 0000_0000_0000_0000_0000b
DESC_P            equ 1000_0000_0000_0000b
DESC_DPL_0        equ 000_0000_0000_0000b
DESC_DPL_1        equ 010_0000_0000_0000b
DESC_DPL_2        equ 100_0000_0000_0000b
DESC_DPL_3        equ 110_0000_0000_0000b
DESC_S_CODE       equ 1_0000_0000_0000b
DESC_S_DATA       equ DESC_S_CODE
DESC_S_SYS        equ 0_0000_0000_0000b
DESC_TYPE_CODE    equ 1000_0000_0000b
DESC_TYPE_DATA    equ 0010_0000_0000b

DESC_CODE_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L_4K + DESC_AVL + DESC_LIMIT_CODE2 + DESC_P + DESC_DPL_0 + DESC_S_CODE + DESC_TYPE_CODE + 0x00
DESC_DATA_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L_4K + DESC_AVL + DESC_LIMIT_DATA2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x00
DESC_VIDEO_HIGH4 equ (0x00 << 24) + DESC_G_4K + DESC_D_32 + DESC_L_4K + DESC_AVL + DESC_LIMIT_VIDEO2 + DESC_P + DESC_DPL_0 + DESC_S_DATA + DESC_TYPE_DATA + 0x0b

RPL0   equ 00b
RPL1   equ 01b
RPL2   equ 10b
RPL3   equ 11b
TI_GDT equ 000b
TI_LDT equ 100b

;---页表相关属性--------------------------------------------------
PAGE_DIR_TABLE_POS equ 0x100000

PG_P    equ 1b
PG_RW_R equ 00b
PG_RW_W equ 10b
PG_US_S equ 000b
PG_US_U equ 100b



















