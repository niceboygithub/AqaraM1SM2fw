ROOTDIR  = $(shell pwd)

COMPILER_PATH=~/rtl8197f/bootcode_rtl8197f/toolchain/msdk-4.4.7-mips-EL-3.10-u0.9.33-m32t-140827/bin/
export CROSS=$(COMPILER_PATH)msdk-linux-

OUTDIR	= ./
CC	= $(CROSS)gcc
AS	= $(CROSS)as
AR	= $(CROSS)ar crs
LD	= $(CROSS)ld
STRIP	= $(CROSS)strip
OBJCOPY = $(CROSS)objcopy


TOOLCFLAGS	=
TOOLLDFLAGS	= -n

OPT	=  -G 0

TEXT	=

INCLUDES	= -I.

CFLAGS	= -march=mips32r2 -g  -fomit-frame-pointer -fno-pic $(TOOLCFLAGS) $(OPT) $(INCLUDES) \
          -D__KERNEL__ \
          -Dlinux \
          -O

TARGET	= boot_ctrl

SRC	= $(TARGET).c

all:
	@$(CC) $(CFLAGS) -o $(OUTDIR)$(TARGET) $(SRC)
	@$(STRIP) $(OUTDIR)$(TARGET)


clean:
	rm $(SRC)