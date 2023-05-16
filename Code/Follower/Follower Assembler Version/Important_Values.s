@Main purpose of this function is initialize values of array
@

.cpu cortex -a53
.fpu neon-fp-armv8

.data 

.text
.align 2
.global Important_Values
.type Important_Values, %function

Important_Values:

	push {fp, lr}
	add fp, sp, #4
	sub sp, sp, #4 
	
	b ploo
	
ploo: 

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
							@x[13] = sts1 					#52
							@x[14] = sts2					#56
							@x[15] = sts3					#60
							@x[16] = l diff					#64
							@x[17] = c diff					#68
							@x[18] = r diff					#72

	mov r0, #225			@x[1] = int Low_Gear = 900		 #4
	mov r0, r0, LSL #2
	str r0, [r10, #4]
	
	mov r0, #250			@x[2] = int Mid_Gear = 1000		 #8
	mov r0, r0, LSL #2	
	str r0, [r10, #8]
	
	mov r0, #150			@x[4] = int HighGear  = 1200	 #12
	mov r0, r0, LSL #3
	str r0, [r10, #12]
	
	mov r0, #7				@x[5] = int minThresh  = 7		 #16
	str r0, [r10, #16]	
	
	mov r0, #10				@x[6] = int minFollowThresh=12   #20
	str r0, [r10, #20]	
	
	mov r0, #14				@x[6] = int Equalibrium = 14     #24	 
	str r0, [r10, #24]
	
	mov r0, #18				@x[7] =int followThresh =18		 #28
	str r0, [r10, #28]		
	
	mov r0, #23				@x[8] =int midThresh=35          #32
	str r0, [r10, #32]		
	
	mov r0, #40				@x[9] =int MaxThresh=40          #36
	str r0, [r10, #36]
	
	mov r0, #105			@x[10] = LEFT= 420			 	 #40
	mov r0, r0, LSL #2
	str r0, [r10, #40]
	
	mov r0, #70				@x[11] = CENTER = 280 		     #44
	mov r0, r0, LSL #2
    str r0, [r10, #44]
	
	mov r0, #180			@x[12] = RIGHT =180   			 #48
	str r0, [r10, #48]		
	
	b exit_Important_Values 
	
	
						
exit_Important_Values:

	sub sp, fp, #4
	pop {fp,pc}
