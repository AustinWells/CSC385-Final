.equ LEGO_BASE, 0xFF200060   
.equ LEGO_DATA, 0x00
.equ LEGO_CTRL, 0x04
.equ ADDR_JP1_IRQ, 0x800 

.equ ADDR_TIMER, 0xFF202000
.equ IRQ_TIMER, 0x01

.equ ADDR_Front_buffer, 0xFF203020
.equ ADDR_Video_in_controller, 0xFF20306C

.equ ADDR_PUSHBUTTONS, 0xFF200050
.equ IRQ_PUSHBUTTONS, 0x02


.equ SEG_ADDR, 0xFF200020

.data

drive_state:
	.byte 0 #0 for stopped, 1 for driving

.text
.global _start

_start: 	


		movia sp, 0x03FFFFFC

		call _init_video
		call _init_timer
	
		#SETTING UP PUSH-BUTTON INTERRUPTS
        movia r2, ADDR_PUSHBUTTONS
        movia r3,0x3	  # Enable interrrupt mask = 0011
        stwio r3,8(r2)  # Enable interrupts on pushbutton 0 and 1
        stwio r3,12(r2) # Clear edge capture register to prevent unexpected interrupt
        
        movia r2, IRQ_PUSHBUTTONS
        ori   r2, r2, IRQ_TIMER
       
        wrctl ctl3,r2   # Enable bit 1 - Pushbuttons use IRQ 1


        movia r2,1
        wrctl ctl0,r2   # Enable global Interrupts on Processor 

		#BEGIN DRIVING
        call drive_forward

STALL_WAIT:
	call drive_brake 

MAIN_LOOP:
        
    movia  r22, LEGO_BASE
    
    movia r4, drive_state
    ldw r4, 0(r4)
    beq r4, r0, STALL_WAIT
	
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
# CAMERA IN STUFF     #
# ################### #
_init_video:

	  	movia r8,ADDR_Video_in_controller
		movi  r9,0x4
		stwio r9,0(r8)        # Enable video in streaming

		movia r8,ADDR_Front_buffer
		movi  r9,0x1
		stwio r9,0(r8)        # Enable double buffer (swap pixel data from back buffer to front buffer)
		ret


#if red is more than 25 then we consider the color to be red
count_red:

	mov  r3, r0 #offset into buffer
    movi r5, 25 #to determine if it's red
    mov  r6, r0 #number of "reds"
    movia r7, 76800 #loop iterations

count_loop:
	
    beq  r0, r7, red_return
    
    ldh  r2, (r3)ADDR_Front_buffer
    movi r4, 0xF8 
    
    slli r4, r4, 11 #take the red component
    and  r2, r2, r4 #place it in r4 and shift it
	srli r2, r2, 11 #to get a number between 0-31
    
    bgeu r5, r2, not_red
	
    addi r6, r6, 1 #we found a red

not_red:
	
    addi r3, r3, 4
    subi r7, r7, 1
	br count_loop

red_return:
	mov r3, r0
    mov r2, r6
	ret

# ################### #
# TIMER STUFF         #
# ################### #
_init_timer:

   movia r7, ADDR_TIMER                    
   stwio r0, 0(r7)   
   
   movui r2, 0x05F4
   stwio r2, 4(r7)                        
   movui r2, 0xE100
   stwio r2, 8(r7)                          # Set the timer for 1 sec
   
   stwio r0, 12(r7)
   stwio r0, 4(r7)                         
	
   movui r2, 5
   stwio r2, 4(r7)                          # Start the timer with interrupts
   ret

# ############## #
# HEX DISPLAY    #
# ############## #
write_stop:
  movia r2,SEG_ADDR
  movia r3,0x6D06BF73
  stwio r3,0(r2)        # Write to 7-seg display 
  ret
  
clear_stop:
  movia r2,SEG_ADDR
  stwio r0,0(r2)        # Write to 7-seg display 
  ret
# ################### #
# INTERRUPT STUFF     #
# ################### #
.section .exceptions, "ax"

interrupt_handler:
    addi sp, sp, -44 # allocate stack space
    stw ra, 0(sp)
	#stw r1, 4(sp)
    stw r2, 8(sp)
	stw r8, 12(sp)
	stw r9, 16(sp)
	stw r10, 20(sp)
	stw r11, 24(sp)
	stw r5, 28(sp)
    stw r3, 32(sp)
    stw r4, 36(sp)
    stw r6, 40(sp)
   	stw r7, 44(sp)
	rdctl et, ipending

read_interrupt:    
	movia r2, IRQ_PUSHBUTTONS
	and r2, r2, et 
	beq r2, r0, check_timer
    br toggle_flag
    
check_timer:
    movia r2, IRQ_TIMER
	and r2, r2, et 
	beq r2, r0, interrupt_epilogue

check_camera:
	call count_red #number of red pixels in camera(stored in r2)
	movia r6, 19200 #check if more than half the screen is red
	bge r2, r6, pause_for_camera
	br handle_timer

pause_for_camera:
	call write_stop
    movia r8, drive_state
    stw r0, 0(r8) #force us to break for button

handle_timer:
	movia r7, ADDR_TIMER
    stwio r0, 0(r7) #clear timeout flag

    movui r2, 5
    stwio r2, 4(r7)
    
	br interrupt_epilogue

toggle_flag:
	call clear_stop
    movia r8, drive_state
    ldw r9, 0(r8)
    movi r10, 0x1
    xor r11, r9, r8 #invert the bit to toggle the state
    stw r11, 0(r8)
    
clear_edge_capture:
    movia r2, ADDR_PUSHBUTTONS
	movi r3, 0x03
	stwio r3, 12(r2) # Clear edge capture register to prevent unexpected interrupt

interrupt_epilogue:
    ldw ra, 0(sp)
	#ldw r1, 4(sp)
    ldw r2, 8(sp)
	ldw r8, 12(sp)
	ldw r9, 16(sp)
	ldw r10, 20(sp)
	ldw r11, 24(sp)
	ldw r5, 28(sp)
    ldw r3, 32(sp)
    ldw r4, 36(sp)
    ldw r6, 40(sp)
   	ldw r7, 44(sp)
	addi sp, sp, 44 # restore registers
	subi ea, ea, 4
	eret
