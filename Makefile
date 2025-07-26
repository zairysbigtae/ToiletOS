ASM = fasm
BOOTLOADER = bootloader/bootloader.asm
STAGE2 = bootloader/second_stage.asm

BOOT_BIN = bootloader.bin
STAGE2_BIN = second_stage.bin
IMG = combined.img

all: $(IMG)

$(BOOT_BIN): $(BOOTLOADER)
	$(ASM) $(BOOTLOADER) $(BOOT_BIN)

$(STAGE2_BIN): $(STAGE2)
	$(ASM) $(STAGE2) $(STAGE2_BIN)

$(IMG): $(BOOT_BIN) $(STAGE2_BIN)
	cat $(BOOT_BIN) $(STAGE2_BIN) > $(IMG)

clean:
	rm -rf $(BOOT_BIN) $(STAGE2_BIN) $(IMG)

run: $(IMG)
	qemu-system-x86_64 -drive format=raw,file=$(IMG)
