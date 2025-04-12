%.bin: %.asm
	nasm -f bin $< -o $@

c.img: main.bin loader.bin
	dd if=main.bin of=c.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=c.img bs=512 count=4 seek=2 conv=notrunc
	rm -rf *.bin


.PHONY:clean
clean:
	rm -rf *.bin

qemu: c.img
	qemu-system-i386 \
	-m 32M \
	-boot c \
	-hda c.img 
