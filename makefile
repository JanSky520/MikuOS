.PHONY: all
all: mikuOS.img

mikuOS.img: mbr.bin loader.bin kernel.bin
	dd if=mbr.bin of=mikuOS.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=mikuOS.img bs=512 count=4 seek=1 conv=notrunc
	dd if=kernel.bin of=mikuOS.img bs=512 count=200 seek=5 conv=notrunc
	rm -rf *.bin
	bochs -q

print.o: lib/kernel/print.S
	nasm -f elf32 -o lib/kernel/print.o lib/kernel/print.asm

kernel.bin: kernel/main.o
	ld -m elf_i386 -Ttext 0x00001500 -e main -o kernel.bin  kernel/main.o lib/kernel/print.o

main.o: kernel/main.c
	gcc -o kernel/main.o -c -m32 -I lib/kernel/ kernel/main.c

%.bin: boot/%.asm
	nasm -f bin $< -o $@

.PHONY:clean
clean:
	rm -rf *.bin

bochs: mikuOS.img
	bochs -dbg

git:
	git add .
	git commit -m "update"
	git push
