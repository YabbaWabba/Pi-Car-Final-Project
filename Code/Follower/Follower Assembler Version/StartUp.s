.cpu cortex -a53
.fpu neon-fp-armv8

.data 
error: 		 .asciz "Setup wiringPi failed!\n"  
errorTwo: 	 .asciz "Please check your setup!\n"
initMessage: .asciz "Initializing Following Robot Program\n"
errorFD:     .asciz "Error in the fd setup!\n"


.text
.align 2
.global StartUp
.type StartUp, %function

StartUp:
	
	
	push {fp, lr}
	add fp, sp, #4
	sub sp, sp, #4 
	
	
	b checkSetup

							@checkup will see if the system is workering 
checkSetup:
	
	bl wiringPiSetup 		@function from follower.c code no arguements need
	cmp r0 , #-1			@the return value should be 1 from true or -1 for false
	beq errorMessage
	
	b initializeSetup 
	
					
errorMessage:
	
	ldr r0, =error			@just displaying error messages in regards to pin setup
	bl printf
	ldr r0, =errorTwo
	bl printf
	b FailedStartUp
	
	
	
initializeSetup:
	
	bl setup  				@function is from follower.c 
	ldr r0, =initMessage 	@letting the user know we are starting the robot
	bl printf
	
	
	@grabbing variable fd the setup with pinbase i2c location 
	@create the varaibles first
	
	mov r0, #75				@first argument is the PIN_BASE VARIBALE
	mov r0, r0, LSL #2		@pin_base should have value of 300     PIN_BASE
	mov r1, #0x40				@0x40		
	mov r2, #50				@HERTZ	
	
	bl pca9685Setup			@after this functions is called, r0 should have the value for fd
	str r0, [r10, #0]        @should store this in the first address of our 'array'
	
	
	@Checking if there was an error of the setup.
	cmp r0, #0
	blt errorInFD
	
	@else enters the beginning phase
	b StartUpSuccess

	
	
errorInFD:
	
	ldr r0, =errorFD
	bl printf
	b exitStartUp
	
				
	
	
FailedStartUp:
	
	mov r0, #-1				@giving the varibale -1 to let know there is error and exit out of entire program
	sub sp, fp, #4
	pop {fp, pc}	
	
	

StartUpSuccess:
	
	
	@'important' remember fd is the first element of our 'array' -> r0
	@SERVO_PIN = 15 -> r1
	@ 3rd argument will be #0 -> r2
	@the 3rd  argument will be left, center and right variables
	@'ADJUSTABLE VARIABLES FOR ROTATIONS' will be r3
	
	
	@looking left 								
	ldr r0, [r10, #0]
	mov r1, #15
	mov r2, #0
	mov r3, #420
	bl pca9685PWMWrite
	
	mov r0, #250			@delaying time by 1 second
	mov r0, r0, LSL #2
	bl delay
	
	
	@looking straight
	ldr r0, [r10, #0]
	mov r1, #15
	mov r2, #0
	mov r3, #70
	mov r3, r3, LSL #2
	bl pca9685PWMWrite
	
	mov r0, #250			@delaying time by 1 second
	mov r0, r0, LSL #2
	bl delay
	
	@looking right 
	
	ldr r0, [r10, #0]
	mov r1, #15
	mov r2, #0
	mov r3, #180
	bl pca9685PWMWrite
	
	mov r0, #250			@delaying time by 1 second
	mov r0, r0, LSL #2
	bl delay
	
	b exitStartUp



exitStartUp:

	mov r0, #1				@1 ==true == start up was a success
	sub sp, fp, #4
	pop {fp,pc}
	



