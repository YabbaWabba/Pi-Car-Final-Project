@Purpose of this function is for the follwer to look and locate a leader/object 
@In order to under the structure, please look at c code and understand the logic in 'Looking Stage'

.cpu cortex -a53
.fpu neon-fp-armv8

.data 
info: 			.asciz "Looking For Leader!\n" 
SlightLeft:		.asciz "1 Slight Left\n"
SharpLeft:		.asciz "4 Sharp Left\n"
SlightRight: 	.asciz "5 Slight Right.\n"	
SharpRight: 	.asciz "8 Sharp Right.\n"
center:			.asciz "Looking Straight.\n"

.text
.align 2
.global Looking
.type Looking, %function


Looking: 

	push {fp, lr}
	add fp, sp, #4
	sub sp, sp, #4
	
	b ViewWest				@first is looking West: Left
	
	
ViewWest:
	
	ldr r0, =info
	bl printf
							@Looking West
	ldr r0, [r10, #0]		@fd argument 
	mov r1, #15				@servo pin
	mov r2, #0				@just zero
	ldr r3, [r10, #40]		@grabbing angle to look at, left
	bl pca9685PWMWrite		
	
	mov r0, #75				@delaying time by .3 of a second
	mov r0, r0, LSL #2		@r3 = 300
	bl delay
	
	bl distance  			@checking our flag sts1
	mov r1, #30				@if something is detected, sts1 =1 
	cmp r0, r1
	ble sts1
	
	mov r0, #0 				@else if sts1 =0
	str r0, [r10, #52]
	
	b ViewNorthWestOne


ViewNorthWestOne:			@Looking North-East, the angle closest to west
		
							
	ldr r0, [r10, #0]		@fd argument 
	mov r1, #15				@servo pin
	mov r2, #0				@just zero
	mov r4, #2
	mov r3, #175
	mul r3, r3, r4		    @grabbing angle to look at: 350
	bl pca9685PWMWrite
	
	mov r0, #75				@delaying time by .3 of a second
	mov r0, r0, LSL #2
	bl delay
	
	bl distance				@checking our flag sts1
	mov r1, #30				@if something is detected, sts1 =1 
	cmp r0, r1
	ble sts1
	
	mov r0, #0 				@else if sts1 =0
	str r0, [r10, #52]
	
	b ViewNorthWestTwo


ViewNorthWestTwo:			@Looking North-West, the angle closest to north

							
	ldr r0, [r10, #0]		@fd argument 
	mov r1, #15				@servo pin
	mov r2, #0				@just zero
	mov r3, #155
	mul r3, r3, r4		    @grabbing angle to look at: 310
	bl pca9685PWMWrite
	
	mov r0, #75				@delaying time by .3 of a second
	mov r0, r0, LSL #2
	bl delay
	
	bl distance  			@checking our flag sts1
	mov r1, #30				@if something is detected, sts1 =1 
	cmp r0, r1
	ble sts1
	
	mov r0, #0 				@else if sts1 =0
	str r0, [r10, #52]
	
	b ViewNorth



ViewNorth:

							@Looking North, the center
	ldr r0, [r10, #0]		@fd argument 
	mov r1, #15				@servo pin
	mov r2, #0				@just zero
	ldr r3, [r10, #44]		@grabbing center angle from memory
	bl pca9685PWMWrite
	
	mov r0, #75				@delaying time by .3 of a second
	mov r0, r0, LSL #2
	bl delay
	
	bl distance  			@checking our flag sts1
	mov r1, #15				@if something is detected, sts2 =3 
	cmp r0, r1
	ble sts2
	
	mov r0, #0 				@else if sts2 =0
	str r0, [r10, #56]
	
	b ViewNorthEastTwo
	


ViewNorthEastTwo:
							@Looking NorthEast, the angle closest to north
	ldr r0, [r10, #0]		@fd argument 
	mov r1, #15				@servo pin
	mov r2, #0				@just zero
	mov r3, #125
	mul r3, r3, r4			@angle is 250
	bl pca9685PWMWrite
	
	mov r0, #75				@delaying time by .3 of a second
	mov r0, r0, LSL #2
	bl delay
	
	bl distance  			@checking our flag sts3
	mov r1, #30				@if something is detected, sts3 =5 
	cmp r0, r1
	ble sts3
	
	mov r0, #0 				@else if sts3 =0
	str r0, [r10, #60]
	
	b ViewNorthEastOne
	
	
	
ViewNorthEastOne:
	
							@Looking NorthEast, the angle closest to east
	ldr r0, [r10, #0]		@fd argument 
	mov r1, #15				@servo pin
	mov r2, #0				@just zero
	mov r3, #225
	bl pca9685PWMWrite
	
	mov r0, #75				@delaying time by .3 of a second
	mov r0, r0, LSL #2
	bl delay
	
	bl distance  			@checking our flag sts1
	mov r1, #30				@if something is detected, sts2 =1 
	cmp r0, r1
	ble sts3
	
	mov r0, #0 				@else if sts3 =0
	str r0, [r10, #60]
	
	b ViewEast
	

ViewEast:					@Looking NorthEast, the angle closest to east

						
	ldr r0, [r10, #0]		@fd argument 
	mov r1, #15				@servo pin
	mov r2, #0				@just zero
	ldr r3, [r10, #48]		@angle to look at
	bl pca9685PWMWrite
	
	mov r0, #75				@delaying time by .3 of a second
	mov r0, r0, LSL #2
	bl delay
	
	bl distance  			@checking our flag sts1
	mov r1, #30				@if something is detected, sts2 =1 
	cmp r0, r1
	ble sts3
	
	mov r0, #0 				@else if sts3 =0
	str r0, [r10, #48]		
	
	b Decide
	
sts1:
	
	str r0, [r10, #64]		@storing the L_Difference in case needs to be compared to another distance
							@r0, should have values of distance
							
	mov r0, #1				@sts1 value = 1
	str r0, [r10, #52]
	
	b ViewNorth				@since this condition is met that must mean that an item was found on the left side
							@automatically view north

sts2:
	
	str r0, [r10, #68]		@storing the C_Difference in case needs to be compared to another distance
							@r0, should have values of sitance
	mov r0, #3			
	str r0, [r10, #56]		@storing sts2 =1 in memory
	
	b ViewNorthEastTwo		@angle closest to North
							@because this condition is met that must mean theres an object to its center, lets look right
	
sts3:
	
	str r0, [r10, #72]		@storing the R_Difference in case needs to be compared to another distance
							@r0, should have values of distance
	
	mov r0, #5
	str r0, [r10, #60]		@storing the value of sts3
	
	b Decide
	
	
Decide:
	
	ldr r0, [r10, #52]		@sts1
	ldr r1, [r10, #56]		@sts2
	ldr r3, [r10, #60]		@sts3
	
	add r0, r0, r1
	add r0, r0, r3			@r0 should have all the values of sts added
	
	cmp r0, #4				@objects detected to center and right
	beq	Left_Center
	
	cmp r0, #8				@objects detected to center and right
	beq	Center_Right
	
	cmp r0, #9				@3 objects detected to follower's surrounding
	beq Surrounded
	
	cmp r0, #1				@only one object was deteced
	beq turningSlightLeft
	
	cmp r0, #3				@only one object was deteced
	beq straightView
	
	cmp r0, #5				@only one object was deteced
	beq turningSlightRight
	
	cmp r0, #0				@nothing was detected
	beq ViewWest


Left_Center:
	
	ldr r0, [r10, #52]		@l_diff
	ldr r1, [r10, #56]		@c_diff
	cmp r0, r1
	blt	turningSlightLeft		@if l_diff is less than turning center


Center_Right:
	
	ldr r0, [r10, #60]		@r_diff
	ldr r1, [r10, #56]		@c_diff
	cmp r0, r1
	blt	turningSlightRight	@if r_diff is less than turning right
	
	
Surrounded:

	ldr r0, [r10, #52]		@l_diff
	ldr r1, [r10, #56]		@c_diff
	cmp r0, r1
	blt tree1 
	
	ldr r0, [r10, #52]		@l_diff
	ldr r1, [r10, #56]		@c_diff
	cmp r0, r1
	bgt tree2
	
	ldr r0, [r10, #56]		@c_diff
	ldr r1, [r10, #60]		@r_diff
	cmp r0, r1
	bgt tree1

tree1:

	ldr r0, [r10, #60]		@r_diff
	ldr r1, [r10, #52]		@l_diff
	cmp r1, r0
	blt turningSharpLeft
	
	ldr r0, [r10, #60]		@r_diff
	ldr r1, [r10, #52]		@l_diff
	cmp r1, r0
	bgt turningSharpRight
	
tree2: 
	
	ldr r0, [r10, #56]		@c_diff
	ldr r1, [r10, #60]		@r_diff
	cmp r0, r1
	blt straightView
	
	b turningSharpRight
	


turningSlightLeft:
	
	ldr r0, =SlightLeft
	bl printf
	
	ldr r0, [r10, #0]		@turning slight left arguments
	mov r1, #250
	mov r1, r1, LSL #3		@r1 = speed = 2000
	mov r2, #0				@no speed  on left wheel
	bl go_left
	
	mov r0, #150			@delay number one
	bl delay
	ldr r0, [r10, #0]
	bl stop_car
	mov r0, #200				@delay number two
	bl delay
	
	b exit_Looking


turningSharpLeft:
	
	ldr r0, =SharpLeft
	bl printf
	
	ldr r0, [r10, #0]		@turning slight left arguments
	mov r4, #20
	mov r1, #150
	mul r1, r1, r4 			@r1 = highspeed = 3000
	
	mov r4, #20
	mov r2, #150
	mul r2, r2, r4			@low speed
	bl go_left
	
	mov r0, #150
	mov r4, #2
	mul r0, r0, r4
	bl delay
	
	ldr r0, [r10, #0]
	bl stop_car
	
	mov r0, #200
	bl delay
	
	b exit_Looking


turningSlightRight:
	
	ldr r0, =SlightRight
	bl printf
	
	ldr r0, [r10, #0]		@turning slight right arguments
	mov r1, #0
	mov r2, #250
	mov r2, r2, LSL #3		@r1 = speed = 2000
	bl go_right
	
	mov r0, #150
	bl delay
	ldr r0, [r10, #0]
	bl stop_car
	mov r0, #200
	bl delay
	
	b exit_Looking

@define short_delay 200
@define long_delay  300
@define extra_long_delay 400

turningSharpRight:
	
	ldr r0, =SharpRight
	bl printf
	
	ldr r0, [r10, #0]		
	mov r1, #150
	mov r4, #10
	mul r1, r1, r4			@low speed
	
	
	mov r2, #150
	mov r4, #20
	mul r2, r2, r4 			@r1 = highspeed = 3000
	bl go_right
	
	mov r0, #150
	mov r4, #2
	mul r0, r0, r4
	bl delay
	
	ldr r0, [r10, #0]
	bl stop_car
	
	mov r0, #200
	bl delay
	
	b exit_Looking
	
straightView:

	ldr r0, [r10, #0]
	bl stop_car
	
	mov r0, #200
	bl delay
	
	b exit_Looking

exit_Looking:

	ldr r0, [r10, #0]	@lookingStraight
	mov r1, #15
	mov r2, #0
	mov r3, #70
	mov r3, r3, LSL #2
	bl pca9685PWMWrite
	
	mov r0, #200
	bl delay
	
	sub sp, fp, #4
	pop {fp,pc}
