%.bin: %.asm
	nasm -f bin $< -o $@

mikuOS.img: main.bin loader.bin
	dd if=main.bin of=mikuOS.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=mikuOS.img bs=512 count=4 seek=2 conv=notrunc
	rm -rf *.bin


.PHONY:clean
clean:
	rm -rf *.bin

bochs: mikuOS.img
	bochs -dbg

git:
	git add .
	git commit -m "update"
	git push
