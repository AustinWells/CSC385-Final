.equ LEGO_BASE, 0xFF200060   
.equ LEGO_DATA, 0x00
.equ LEGO_CTRL, 0x04

.global _start

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

_start:
