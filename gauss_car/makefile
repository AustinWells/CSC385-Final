# Created by the Intel FPGA Monitor Program
# DO NOT MODIFY

############################################
# Global Defines
DEFINE_COMMA	:= ,

############################################
# Compilation Targets

# Programs
AS		:= nios2-elf-as
CC		:= nios2-elf-gcc
LD		:= nios2-elf-ld
OC		:= nios2-elf-objcopy
RM		:= rm -f

# Flags
USERCCFLAGS	:= -g -O1 -ffunction-sections -fverbose-asm -fno-inline -mno-cache-volatile
ARCHASFLAGS	:= --gstabs -I "/root/intelFPGA/18.1/nios2eds/components/altera_nios2/sdk/inc/"
ARCHCCFLAGS	:= -mno-hw-mul -mno-hw-div -I "/root/intelFPGA/18.1/nios2eds/components/altera_nios2/HAL/inc/" -DSYSTEM_BUS_WIDTH=32 -DALT_SINGLE_THREADED -D_JTAG_UART_BASE=4280291328u
ARCHLDFLAGS	:= --defsym nasys_stack_top=0x4000000 --defsym nasys_program_mem=0x0 --defsym nasys_data_mem=0x0
ARCHLDSCRIPT	:= --script="/root/intelFPGA/18.1/University_Program/Monitor_Program/build/nios_as_build.ld"
ASFLAGS		:= $(ARCHASFLAGS)
CCFLAGS		:= -Wall -c $(USERCCFLAGS) $(ARCHCCFLAGS)
LDFLAGS		:= $(ARCHLDFLAGS) $(ARCHLDSCRIPT) -e _start -u _start
OCFLAGS		:= -O srec

# Files
HDRS		:=
SRCS		:= main_driver.s
OBJS		:= $(patsubst %, %.o, $(SRCS))

# Targets
compile: main_driver.srec

main_driver.srec: main_driver.elf
	$(RM) $@
	$(OC) $(OCFLAGS) $< $@

main_driver.elf: $(OBJS)
	$(RM) $@
	$(LD) $(LDFLAGS) $(OBJS) -o $@

%.c.o: %.c $(HDRS)
	$(RM) $@
	$(CC) $(CCFLAGS) $< -o $@

%.s.o: %.s $(HDRS)
	$(RM) $@
	$(AS) $(ASFLAGS) $< -o $@

clean:
	$(RM) main_driver.srec main_driver.elf $(OBJS)

