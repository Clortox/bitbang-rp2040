ENTRY = boot2blink
COMPCRC = compCrc32
CRCDIR = crc
CRCSRC = crc

BUILDDIR = build
SRCDIR = src

LINKSCRIPT = $(SRCDIR)/link.ld

TOOLCHAIN = arm-none-eabi-
CFLAGS ?= -mcpu=cortex-m0plus
LDFLAGS ?= -T $(LINKSCRIPT) -nostdlib

UTILS = ./utils

.PHONY: clean build

build: buildDir $(BUILDDIR)/$(ENTRY).bin $(BUILDDIR)/$(ENTRY).uf2 copyUF2

buildDir:
	mkdir -p $(BUILDDIR)

clean:
	rm -rf $(BUILDDIR) $(ENTRY).uf2

$(BUILDDIR)/$(ENTRY).bin: $(SRCDIR)/$(ENTRY).c
	$(TOOLCHAIN)gcc $(CFLAGS) $(SRCDIR)/$(ENTRY).c -c -o $(BUILDDIR)/$(ENTRY)_temp.o
	$(TOOLCHAIN)objdump -hSD $(BUILDDIR)/$(ENTRY)_temp.o > $(BUILDDIR)/$(ENTRY)_temp.objdump
	$(TOOLCHAIN)objcopy -O binary $(BUILDDIR)/$(ENTRY)_temp.o $(BUILDDIR)/$(ENTRY)_temp.bin
	g++ -I $(UTILS) $(CRCDIR)/$(COMPCRC).cpp -o $(BUILDDIR)/$(COMPCRC).out
	./$(BUILDDIR)/$(COMPCRC).out $(BUILDDIR)/$(ENTRY)_temp.bin
	$(TOOLCHAIN)gcc $(SRCDIR)/$(ENTRY).c $(BUILDDIR)/$(CRCSRC).c $(CFLAGS) $(LDFLAGS) -o $(BUILDDIR)/$(ENTRY).elf
	$(TOOLCHAIN)objdump -hSD $(BUILDDIR)/$(ENTRY).elf > $(BUILDDIR)/$(ENTRY).objdump
	$(TOOLCHAIN)objcopy -O binary $(BUILDDIR)/$(ENTRY).elf $@

$(BUILDDIR)/$(ENTRY).uf2: $(BUILDDIR)/$(ENTRY).bin
	python3 $(UTILS)/uf2/utils/uf2conv.py -b 0x10000000 -f 0xe48bff56 -c $(BUILDDIR)/$(ENTRY).bin -o $@

copyUF2: $(BUILDDIR)/$(ENTRY).uf2
	cp $(BUILDDIR)/$(ENTRY).uf2 ./$(ENTRY).uf2





