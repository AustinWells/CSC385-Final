.equ LEGO_BASE, 0xFF200060   
.equ LEGO_DATA, 0x00
.equ LEGO_CTRL, 0x04

.equ ADDR_JP1, 0xFF200060 
.equ ADDR_JP1_IRQ, 0x800 

.global _start
_start: 	

    movia r8, ADDR_JP1 		  # load address GPIO JP1 into r8
    movia r9, 0x07f557ff      # set motor,threshold and sensors bits to output, set state and sensor valid bits to inputs 
    stwio r9, 4(r8)
 	
	# and set sensor 0 to threshold to 5 and enable motor
	movia r9, 0xfabffbfe
	stwio r9, 0(r8)

	# and set sensor 1 to threshold to 5 and enable motor
	movia r9, 0xfabfeffe
	stwio r9, 0(r8)

	# disable threshold register and enable state mode
	movia r9, 0xfadffffe
	stwio r9, 0(r8)
	
	#Write to Edge Capture Register to clear
	movia r9, 0xFFFFFFFF 
	stwio r9, 12(r8) 
	
	movia r9, 0x18000000 
	stwio r9, 8(r8)

	movia r8, ADDR_JP1_IRQ 
	wrctl ctl3, r8

	movia r8, 1
	wrctl ctl0, r8  

LOOP:
	br LOOP

# ################# #
# DRIVING FUNCTIONS #
# ################# # ########################################
# Motor0 = left tyre                                         #
# Motor1 = right tyre                                        #
#                                                            #
# We use a differential steering. Meaning to turn left you   #
# simply turn off left motor, go forward with right motor.   #
# ############################################################
drive_forward:
	movia  r8, LEGO_BASE     

	movia  r9, 0x07f557ff       # set direction for motors to all output 
	stwio  r9, 4(r8)

	movia	 r9, 0xFFFFFFF0       # motor0 enabled, direction forward (00)
                                  # motor1 enabled, direction forward (00)
	stwio	 r9, 0(r8)
	ret
  
drive_reverse:
	movia  r8, LEGO_BASE     

	movia  r9, 0x07f557ff       # set direction for motors to all output 
	stwio  r9, 4(r8)

	movia	 r9, 0xFFFFFFFA       # motor0 enabled, direction reverse (10)
                                  # motor1 enabled, direction forward (10) 
	stwio	 r9, 0(r8)
	ret

turn_left:
	movia  r8, LEGO_BASE     

	movia  r9, 0x07f557ff       # set direction for motors to all output 
	stwio  r9, 4(r8)

	movia	 r9, 0xFFFFFFF3       # motor0 disabled, motor1 enabled, direction forward. (0011)
	stwio	 r9, 0(r8)
	ret
    
turn_right:
	movia  r8, LEGO_BASE     

	movia  r9, 0x07f557ff       # set direction for motors to all output 
	stwio  r9, 4(r8)

	movia	 r9, 0xFFFFFFFC       # motor0 disabled, motor1 enabled, direction forward. (1100)
	stwio	 r9, 0(r8)
	ret
	
# ################# #
# HANDLER STUFF     #
# ################# #
.section .exceptions, "ax"

interrupt_handler:
	# store stack stuff
	
	
	rdctl et, ctl4
	andi et, et, 0x800 # check if interrupt pending from IRQ11	
	movia r2, ADDR_JP1_IRQ
	and r2, r2, et 
	beq r2, r0, interrupt_epilogue
	
UART_handler:
	# do stuff here -- check which sensor, take appropriate action, etc...

interrupt_epilogue:
	# load back into stack
	
	eret
	
	
