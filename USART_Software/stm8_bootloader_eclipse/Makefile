## STM8S
MCU     ?= stm8s003f3
FAMILY  ?= STM8S

## STM8L
# MCU     ?= stm8l051f3
# FAMILY  ?= STM8L

ARCH     = stm8

ProjectName            :=$(project_name)
SourceDirectory        :=.
BuildDirectory         :=Release

TARGET  ?= $(ProjectName).ihx

SRCS    := $(wildcard *.c)
ASRCS   := $(wildcard *.s)

OBJS     = $(SRCS:.c=.rel)
OBJS    += $(ASRCS:.s=.rel)

OBJSlinker     = $(addprefix $(BuildDirectory)/,$(SRCS:.c=.rel))
OBJSlinker    += $(addprefix $(BuildDirectory)/,$(ASRCS:.s=.rel))

list_c_files           := $(notdir $(wildcard $(SourceDirectory)/*.c))
list_s_files           := $(notdir $(wildcard $(SourceDirectory)/*.s))

list_files_rel          = $(addprefix $(BuildDirectory)/,$(patsubst %,%.rel,$(list_c_files)))
list_files_rel         += $(addprefix $(BuildDirectory)/,$(patsubst %,%.rel,$(list_s_files)))

CC       = sdcc
LD       = sdld
AS       = sdasstm8
##ASFLAGS  = -plosgff
ASFLAGS  = -plsgff -o $(BuildDirectory)/$@
OBJCOPY  = sdobjcopy
CFLAGS   = -m$(ARCH) -p$(MCU) -D$(FAMILY) -I.
CFLAGS  += --stack-auto --noinduction --use-non-free --noinvariant --opt-code-size -o $(BuildDirectory)/$@
#CFLAGS  += --stack-auto --noinduction --use-non-free -o $(BuildDirectory)/$@
# -o $(BuildDirectory)/$@
LDFLAGS  = -m$(ARCH) -l$(ARCH) --out-fmt-ihx
LDFLAGS += -Wl-bIVT=0x8000 -Wl-bGSINIT=0x8080

all: $(TARGET) size

$(TARGET): $(OBJS)
	@echo Linking $(TARGET):;
	$(CC) -o $(BuildDirectory)/$@ $(OBJSlinker) $(LDFLAGS) 

%.rel: %.s
	@echo Compiling files *.s:;
	$(AS) $(ASFLAGS) $<

%.rel: %.c
	@echo Compiling files *.c:;
	$(CC) $(CFLAGS) -c $< 

flash: $(TARGET)
	stm8flash -c stlinkv2 -p $(MCU) -w $(TARGET)

clean:
	@echo Clean $(BuildDirectory)/:;
	rm -f $(BuildDirectory)/*.*
#	rm -f *.map *.rel *.ihx *.o *.sym *.lk *.lst *.rst *.cdb *.bin *.asm

size:
	@$(OBJCOPY) -I ihex --output-target=binary $(BuildDirectory)/$(TARGET) $(BuildDirectory)/$(TARGET).bin
	@echo "-----\nImage size:"
	@stat -L -c %s $(BuildDirectory)/$(TARGET).bin

## @TODO: separate option-bytes for stm8s and stm8l!
# enable write-protection on first 10 pages
opt-set:
	@echo '0x00 0x09 0xf6 0x00 0xff 0x00 0xff 0x00 0xff 0x00 0xff' | xxd -r > opt.bin
	stm8flash -c stlinkv2 -p stm8s003f3 -s opt -w opt.bin

# reset option-bytes to factory defaults
opt-reset:
	@echo '0x00 0x00 0xff 0x00 0xff 0x00 0xff 0x00 0xff 0x00 0xff' | xxd -r > opt.bin
	stm8flash -c stlinkv2 -p stm8s003f3 -s opt -w opt.bin

dump-opt:
	stm8flash -c stlinkv2 -p $(MCU) -s opt -r dump_opt.bin

dump-flash:
	stm8flash -c stlinkv2 -p $(MCU) -s flash -r dump_flash.bin

erase:
	tr '\000' '\377' < /dev/zero | dd of=empty.bin bs=8192 count=1
	stm8flash -c stlinkv2 -p $(MCU) -s flash -w empty.bin

.PHONY: clean all flash size dump-opt dump-flash erase
