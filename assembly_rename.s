.equ LEGO_BASE, 0xFF200060   
.equ LEGO_DATA, 0x00
.equ LEGO_CTRL, 0x04
.equ ADDR_JP1_IRQ, 0x800 

.global _start
_start: 	

MAIN_LOOP:
	call drive_forward
    movia  r22, LEGO_BASE
	
    left:
    #read left
    	ldwio  r17,  0(r22)
		movia  r16, 0xffffff00
		or   r17, r17, r16
		movia  r16, 0xfffeffff
		and  r17, r17, r16
		
		stwio  r17, 0(r22)
		ldwio  r18,  0(r22)          # checking for valid data sensor 3
		srli   r19,  r18,17          # bit 17 is valid bit for sensor 3           
		andi   r19,  r19,0x1
		bne    r0,  r19,left        #invalid
    
    left_good:
	    srli   r18, r18, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
	    andi   r20, r18, 0x0f

	#read right
	right:
		ldwio  r17,  0(r22)
		movia  r16, 0xfffffb00
		or   r17, r17, r16
		movia  r16, 0xfffffbff
		and  r17, r17, r16
		
		stwio  r17, 0(r22)
		ldwio  r18,  0(r22)          # checking for valid data sensor 3
		srli   r23,  r18,11          # bit 17 is valid bit for sensor 3           
		andi   r23,  r23,0x1
		bne    r0,  r23,right        #invalid
        
    right_good:
	    srli   r18, r18, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
	    andi   r21, r18, 0x0f 
    
    change:
		bgtu r21, r20, motor_left
		bgeu r20, r21, motor_right
    
	br MAIN_LOOP

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
	
	
	#rdctl et, ctl4
	#andi et, et, 0x800 # check if interrupt pending from IRQ11	
	#movia r2, ADDR_JP1_IRQ
	#and r2, r2, et 
	#beq r2, r0, interrupt_epilogue
	
UART_handler:
	# do stuff here -- check which sensor, take appropriate action, etc...

interrupt_epilogue:
	# load back into stack
	
	eret
	
	
