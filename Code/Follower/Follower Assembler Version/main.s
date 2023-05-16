@Code by Josh 
@Final Project: Robot Follower
@'Order for files to be opened and examined'
@ 1. main
@ 2. Important_Values
@ 3. StartUp.
@ 4. Follower
@ 5. Scaling
@ 6. Looking

@***Informations***
@This the main function
@initializes array and enters Follower's actions

.cpu cortex -a53
.fpu neon-fp-armv8

.data 
@incase texts needs to be inserted

.text
.align 2
.global main
.type main, %function


main:
	
	push {fp, lr}
	add fp, sp, #4
	sub sp, sp, #4 		
	
	@CREATING AN ARRAY. lets just 12 memory blocks for now
							@holds important variables
	mov r0, #19									
	mov r0, r0, LSL #2 		@creating a total of 76 bytes  LSL 2 = x4
	sub sp, sp, r0 		
	str sp, [fp, #-8]
	
	ldr r10, [fp, #-8] 		@r10 will hold x[0] aka the beginning of the array
							
							@'LOG ENTRY FOR ARRAY'
							@x[0] = 'int fd' essential value for the functions created in c  #0
							@ this term in initialized in StartUp function
									
							@following elements are meant for easy change
							@'most changed/adjusted variables'
							@x[0] = fd						#0
							@x[1] = int Low_Gear = 900		#4
							@x[2] = int MidGear				#8
							@x[3] = int HighGear			#12
							@x[4] = int minThresh     		#16
							@x[5] = int minFollowThresh		#20
							@x[6] = int Equalibrium         #24
							@x[7] = int followThresh		#28
							@x[8] = int midThresh			#32
							@x[9] = int	MaxThresh			#36
							@x[10] = LEFT				 	#40
							@x[11] = CENTER 				#44
							@x[12] = RIGHT    				#48
							@x[13] = sts1 					#52			Term is initalized in Follower function
							@x[14] = sts2					#56			Term is initalized in Follower function
							@x[15] = sts3					#60			Term is initalized in Follower function
							@x[16] = l diff					#64			Term is initalized in Follower function
							@x[17] = c diff					#68			Term is initalized in Follower function
							@x[18] = r diff					#72			Term is initalized in Follower function
	
	
	bl Important_Values		@Initialzing Values for functions
	
	bl StartUp 				@Initialzing Robot
	cmp r0, #-1				@value is returned 1==success -1==failed
	beq end
	
	b loops					@originally this function was supposed to bl Follower (branch into follower)
	
	beq end
	
	
loops:

		
	mov r0,	#100 					@performing a long_delay 300
	mov r0, r0, LSL #2
	bl delay
	

	ldr r0, [r10, #0]				@looking straight
	mov r1, #15
	mov r2, #0
	ldr r3, [r10, #44]
	bl pca9685PWMWrite
	
									@while (distance() =< MaxThresh)
	bl distance 					@gauging distance, the value should be in r0
	ldr r1, [r10, #36]				@Grabbing the value of maxThresh
	cmp r0, r1
	ble Scaling 
	
	
	bl distance
	
	ldr r1, [r10, #36]				@Grabbing the value of maxThresh
	cmp r0, r1
	bgt Looking
	
	b loops
		
end:
	sub sp, fp, #4
	pop {fp,pc}
