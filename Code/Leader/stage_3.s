@ Stage 3: Return to course
@ Move the same number of times back on track that the robot had to deviate off the course initially
@ Once the robot has moved back the same number of steps, then the robot will turn left.

.cpu 	    cortex-a53
.fpu 	    neon-fp-armv8

.equ      OBSTACLE, 40
.equ      MID_SPEED, 2000

.text
.align    2
.global   stage_3
.type     stage_3, %function

stage_3:
	push    {fp, lr}	    @ Initializing
	add     fp, sp, #4
	sub     sp, sp, #4
stage_3_loop:
  @ Use the number of steps the robot needed to take to move away from
  @ the obstacle in stage 1 as a counter for how many steps to take
  @ to get back on course
  mov     r1, #0
  cmp     r5, r1
  beq     transition_to_end
  mov     r0, #1
  bl      step_forward
  sub     r5, #1
  b       stage_3_loop
transition_to_end:
  @ Step forward three steps for additional balance
  mov     r0, #3
  bl      step_forward
  @ Turn left
  mov     r0, r4
  mov     r1, #0
  mov     r2, #MID_SPEED
  bl      go_Left
  mov     r0, #600
  bl      delay
  mov     r0, r4
  @ Stop the car and wait
  bl      stop_car
  mov     r0, #200
  bl      delay
quit:
	sub	    sp, fp, #4	        @ Beginning termination
	pop	    {fp, pc}
    
