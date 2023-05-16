@Main actions are taken in this function
@


.cpu cortex -a53
.fpu neon-fp-armv8

.data 

.text
.align 2
.global Follower
.type Follower, %function


@information: the outer while loop, start doing the commands and the fucntions part1
Follower: 
	
	push {fp, lr}
	add fp, sp, #4
	sub sp, sp, #4 
	
Loop:								
	
	mov r0,	#75 					@performing a long_delay 300
	mov r0, r0, LSL #2
	bl delay
	
	
	@looking straight
	ldr r0, [r10, #0]
	mov r1, #15
	mov r2, #0
	ldr r3, [r10, #44]
	bl pca9685PWMWrite
	
	
	
					@while (distance() < MaxThresh || distance() == MaxThresh)
	
	bl distance 					@gauging distance, the value should be in r0
	ldr r1, [r10, #36]				@Grabbing the value of maxThresh
	cmp r0, r1
	ble Scaling 
	
	bl Looking
	
	b Loop
	
exit_loop:

	sub sp, fp, #4
	pop {fp,pc}

