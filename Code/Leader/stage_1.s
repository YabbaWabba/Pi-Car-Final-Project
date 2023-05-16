@ Stage 1: Deviate from the course
@ Focus the sensor on the right. Keep moving forward until there isn't anything to the right.
@ If there is nothing to the right, stop and turn right.
@ During this stage, we will track how many times the robot has to move forward with 'move' (relevant to the last step)

.cpu 	    cortex-a53
.fpu 	    neon-fp-armv8

.equ      THRESHOLD, 70
.equ      MID_SPEED, 2000

.text
.align	  2
.global	  stage_1
.type     stage_1, %function

stage_1:
  push    {fp, lr}            @ Initializing
  add     fp, sp, #4
  sub     sp, sp, #4
stage_1_loop:
  @ Check if sonar sees the obstacle
  @ If the obstacle is still present, keep moving.
  @ Otherwise, turn right
  bl      distance
  mov     r6, r0
  mov     r1, #THRESHOLD
  cmp     r6, r1
  bgt     transition_to_s2
  ble     stage_1_step
stage_1_step:
  @ Add to the step counter in register 5 every time the robot steps forward
  mov     r0, r6
  mov     r1, r7
  bl      course_correct
  mov     r7, r6
  mov     r0, #3
  bl      step_forward
  add     r5, #1
  b       stage_1_loop
transition_to_s2:
  @ Move forward four times (give the robot some clearance before rotating)
  mov     r0, #4              
  bl      step_forward
  add     r5, #4
  @ Turning right
  mov     r0, r4
  mov     r1, #MID_SPEED
  mov     r2, #0
  bl      go_Right
  mov     r0, #500
  bl      delay
  @ Stop and wait
  mov     r0, r4
  bl      stop_car
  mov     r0, #200
  bl      delay
quit:
	sub	sp, fp, #4	        @ Beginning termination
	pop	{fp, pc}
