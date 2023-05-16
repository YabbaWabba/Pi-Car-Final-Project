@This function is entered if the follower robot has detected the leader
@Actions: stop slow regular speed and high speed are taken

.cpu cortex -a53
.fpu neon-fp-armv8

.data 
eqb: 		.asciz "Equalibrium distance!\n" 
regSpeed: 	.asciz "REGULAR SPEED!\n"
slSpeed:	.asciz "Too Close: SLOW SPEED!\n"
HiSpeed: 	.asciz "Too Far: HIGH SPEED!\n"
TooClose:   .asciz  "Too Close!!! Backing Up!\n"

.text
.align 2
.global Scaling
.type Scaling, %function


Scaling: 
	
	push {fp, lr}
	add fp, sp, #4
	sub sp, sp, #4 
	
	b loop
	
loop:
	
	
								@if (distance() == Equalibrium)
	ldr r1, [r10, #24]			@r1 will have the value of 'Equalibrium'
	cmp r0, r1    				@r0, should already have the distance from calling function
	beq Equalibrium
	
	
								@if ( (distance() >followThresh)
	ldr r1, [r10, #28]			@r1 should have the value of 'followThresh'
	cmp  r0, r1					@r0, should already have distance from calling function
	bge UpperDivisionSpeeds		
	
								
	ldr r1, [r10, #16]			@ grabbing values min thresh from memory
	ble Stop_Back				@stops car
	
	
								@if(distance() < Equalibrium)
	ldr r1, [r10, #24]			@r1 will have the value of 'Equalibrium'
	cmp r0, r1    				@r0, should already have the distance
	blt LowerDivisionSpeed
	
	
@***Information**
@ stop car if its at the right distance
@ the middle between max/min threshholds
@status checked 
Equalibrium:
	
	ldr r0, =eqb
	bl printf 					@message for user
	
	ldr r0, [r10, #0]			@grabbing variable for 'fd' 
	bl stop_car					@takes the input argument of fd
	mov r0, #200				@delay before action is taking
	bl delay
				
	b Look_Straight			


@***Information**
@ Goes to regular speed or fast speed
@status checked
UpperDivisionSpeeds:
	
	ldr r1, [r10, #32]			@if speed is lower or equal than midThresh
	cmp r0,	r1
	blt Regular_Speed
	
	ldr r1, [r10, #36] 			@if max thresh < distance stop and exit scaling
	cmp r0, r1
	b exit_Scaling
	
	b High_Speed				@otherise go high speed


@***Information**
@ branches backs up/ slow speed
@status: checked
LowerDivisionSpeed:
	
	ldr r1, [r10, #20] 			@grabbing value of minFollowThresh
	cmp r0, r1					@r0 should still have distance
	bge Low_Speed				@distance>= minfollowthresh go to slow speed

	
Low_Speed:

	ldr r0, =slSpeed
	bl printf 
	
	ldr r0, [r10, #0] 			@grabbing fd argument
	ldr r1, [r10, #4]			@grabbing Slow_Gear
	bl go_advance				@branch into g_advance function move forward with corresponding speed.
	
	b Look_Straight
		
Regular_Speed:
	
	ldr r0, =regSpeed
	bl printf 
	
	ldr r0, [r10, #0] 			@grabbing fd argument
	ldr r1, [r10, #8]			@grabbing Mid_Gear
	bl go_advance				@move forward with corresponding speed.

	b Look_Straight
	
High_Speed:

	ldr r0, =HiSpeed
	bl printf 
	
	ldr r0, [r10, #0] 			@grabbing fd argument
	ldr r1, [r10, #12]			@grabbing 'High_Gear'
	bl go_advance				@move forward with corresponding speed.
	
	mov r0, #250				@delaying for one second
	mov r0, r0, LSL #2
	bl delay
	
	ldr r0, [r10, #0]			@stopping car
	bl stop_car 
	
	b Look_Straight

Stop_Back:
	
	ldr r0, =TooClose
	bl printf
	
	ldr r0, [r10, #0]			@stopping car arguemnt is fd
	bl stop_car
	
	b Look_Straight



@***Information***
@ Looking Straight to send sonar waves
@ should return with r0 having the distance
@returns to main loop if conditions are made

Look_Straight:
	
	mov r0, #200				@delay before action is taking
	bl delay					@needed for robot actions to catch up
	
	ldr r0, [r10, #0]			@looking straight
	mov r1, #15
	mov r2, #0
	mov r3, #70
	mov r3, r3, LSL #2
	bl pca9685PWMWrite
	
	mov r0, #200				@delay before action is taking
	bl delay
	
	
	b exit_Scaling
	

exit_Scaling:
	
	@exiting towards follower/main function
	sub sp, fp, #4
	pop {fp,pc}
	
	
	
	
	
