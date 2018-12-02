.equ LEGO_BASE, 0xFF200060   
.equ LEGO_DATA, 0x00
.equ LEGO_CTRL, 0x04
.equ ADDR_JP1_IRQ, 0x800 

.equ ADDR_PUSHBUTTONS, 0xFF200050
.equ IRQ_PUSHBUTTONS, 0x02

.global _start
_start: 	

		#SETTING UP PUSH-BUTTON INTERRUPTS
        movia r2, ADDR_PUSHBUTTONS
        movia r3,0x3	  # Enable interrrupt mask = 0011
        stwio r3,8(r2)  # Enable interrupts on pushbutton 0 and 1
        stwio r3,12(r2) # Clear edge capture register to prevent unexpected interrupt
        
        movia r2, IRQ_PUSHBUTTONS
        wrctl ctl3,r2   # Enable bit 1 - Pushbuttons use IRQ 1

        movia r2,1
        wrctl ctl0,r2   # Enable global Interrupts on Processor 

		#BEGIN DRIVING
        call drive_forward

MAIN_LOOP:
        
    movia  r22, LEGO_BASE
	
    right:
    	#read right
    	ldwio  r17,  0(r22)
		movia  r16, 0xffffff00
		or   r17, r17, r16
		movia  r16, 0xfffeffff
		and  r17, r17, r16
		
		stwio  r17, 0(r22)
		ldwio  r18,  0(r22)          # checking for valid data sensor 3
		srli   r19,  r18,17          # bit 17 is valid bit for sensor 3           
		andi   r19,  r19,0x1
		bne    r0,  r19,right        #invalid
    
    	right_valid:
	    	srli   r18, r18, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
	    	andi   r20, r18, 0x0f

	#read left
	left:
		ldwio  r17,  0(r22)
		movia  r16, 0xfffffb00
		or   r17, r17, r16
		movia  r16, 0xfffffbff
		and  r17, r17, r16
		
		stwio  r17, 0(r22)
		ldwio  r18,  0(r22)          # checking for valid data sensor 3
		srli   r23,  r18,11          # bit 17 is valid bit for sensor 3           
		andi   r23,  r23,0x1
		bne    r0,  r23,left        #invalid
        
    	left_valid:
	    	srli   r18, r18, 27          # shift to the right by 27 bits so that 4-bit sensor value is in lower 4 bits 
	    	andi   r21, r18, 0x0f 
    
    steer:
        #r20 holds value of right, r21 holds value of left
        movia r22, 0x5 # this is our threshold. if you go over this, the sensor is on the black
	
	bgtu r20, r22, steer_left
    bgtu r21, r22, steer_right
    
    all_clear:
    	call drive_forward
    
	br MAIN_LOOP

    
    steer_left:
		bgtu r21, r22, steer_reverse
        call turn_left
        br MAIN_LOOP
        
    steer_right:
        call turn_right
        br MAIN_LOOP
		
	steer_reverse:
		call drive_reverse
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
drive_brake:
    movia  r8, LEGO_BASE     

    movia  r9, 0x07f557ff       # set direction for motors to all output 
    stwio  r9, 4(r8)

    movia	 r9, 0xFFFFFFFF       # motor0 enabled, direction forward (00)
                                  # motor1 enabled, direction forward (00)
    stwio	 r9, 0(r8)
    ret

drive_reverse:
	movia  r8, LEGO_BASE     

	movia  r9, 0x07f557ff       # set direction for motors to all output 
	stwio  r9, 4(r8)

	movia	 r9, 0xFFFFFFF0       # motor0 enabled, direction forward (00)
                                  # motor1 enabled, direction forward (00)
	stwio	 r9, 0(r8)
	ret
  
drive_forward:
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

	movia	 r9, 0xFFFFFFFB      # motor0 disabled, motor1 enabled, direction forward. (0011)
	stwio	 r9, 0(r8)
	ret
    
turn_right:
	movia  r8, LEGO_BASE     

	movia  r9, 0x07f557ff       # set direction for motors to all output 
	stwio  r9, 4(r8)

	movia	 r9, 0xFFFFFFFE      # motor0 disabled, motor1 enabled, direction forward. (1100)
	stwio	 r9, 0(r8)
	ret


# ################### #
# INTERRUPT STUFF     #
# ################### #
.section .exceptions, "ax"

interrupt_handler:
	# store stack stuff
	
read_interrupt:    
	#rdctl r1, ctl4
	#andi r1, r1, 0x02 # check if interrupt from push buttons
	#movia r2, IRQ_PUSHBUTTONS
	#and r2, r2, et 
	#beq r2, r0, interrupt_epilogue

STOP:
	# do stuff here 
    
    	#call drive_brake
	br STOP

interrupt_epilogue:
	# load back into stack
	
	subi ea, ea, 4
	eret
