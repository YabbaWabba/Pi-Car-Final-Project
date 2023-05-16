@ Stage 0: Identify obstacle
@ Check if there's anything in front
@ If there isn't keep going. If there is, then stop and turn left

.cpu 	    cortex-a53
.fpu 	    neon-fp-armv8

.equ      OBSTACLE, 40
.equ      MID_SPEED, 2000

.text
.align    2
.global   stage_0
.type     stage_0, %function

stage_0:
	push    {fp, lr}	          @ Initializing
	add     fp, sp, #4
	sub     sp, sp, #4
stage_0_loop:
	@ Check if sonar sees the obstacle
	@ If the obstacle is still present, keep moving.
	@ Otherwise, turn left
	bl      distance
	mov     r6, r0
	mov     r1, #OBSTACLE
	cmp     r6, r1
	bgt     stage_0_step
	ble     transition_to_s1
stage_0_step:
  	@ Move forward
	mov     r0, #2
	bl      step_forward
	b       stage_0_loop
transition_to_s1:
  	@ Turn left and then stop the car
	mov     r0, r4
	mov     r1, #0
	mov     r2, #MID_SPEED
	bl      go_Left
	mov     r0, #600
	bl      delay
	mov     r0, r4
	bl      stop_car
quit:
	sub	    sp, fp, #4	        @ Beginning termination
	pop	    {fp, pc}
