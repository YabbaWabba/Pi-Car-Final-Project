@ Stage 2: Moving past the obstacle
@ First, have the robot keep moving forward until it sees something to the right again (this accounts for when the robot might initially enter Stage 1 a good distance away from the obstacle)
@ Once it sees the obstacle, keep moving forward until there's nothing to the right anymore.
@ If there's nothing to the right, turn right.

.cpu 	    cortex-a53
.fpu 	    neon-fp-armv8

.equ      THRESHOLD, 70
.equ      MID_SPEED, 2000

.text
.align	  2
.global	  stage_2
.type 	  stage_2, %function

stage_2:
	push    {fp, lr}	                @ Initializing
	add     fp, sp, #4
	sub     sp, sp, #4
	mov	r7, #0
look_for_obstacle:
  @ Because there is some distance between the robot when it turned and the obstacle,
  @ the robot will need to move forward a bit until it can see the obstacle again.
  @ For this reason, the robot will keep moving forward until it sees the obstacle.
  bl       distance
  mov     r6, r0
  mov     r1, #THRESHOLD
  cmp     r6, r1
  bgt     step_search
  ble     move_past_obstacle_loop
step_search:
  @ Move forward and then check again if there is an obstacle to the right
  mov     r0, #1
  bl      step_forward
  b       look_for_obstacle     
move_past_obstacle_loop:
  @ Once the robot sees the obstacle, it will keep moving forward until 
  @ it can no longer see the obstacle. At which point, it turns right.
  bl      distance
  mov     r6, r0
  mov     r1, #THRESHOLD
  cmp     r6, r1
  blt     stage_2_step
  bge     transition_to_s3
stage_2_step:
  @ Do some course correction and then step forward.
  @ Course correction deals with any mismatch in motor strength or timing on the vehicle
  mov     r0, r6
  mov     r1, r7
  bl      course_correct
  mov     r7, r6
  mov     r0, #1
  bl      step_forward
  b       move_past_obstacle_loop
transition_to_s3:
  @ Move forward four times (give the robot some clearance before rotating)
  mov     r0, #4
  bl      step_forward
  add     r5, #4
  @ Turn right
  mov     r0, r4
  mov     r2, #0
  mov     r1, #MID_SPEED
  bl      go_Right
  mov     r0, #550
  bl      delay
  @ Stop and wait
  mov     r0, r4
  bl      stop_car
  mov     r0, #200
  bl      delay 
quit:
	sub	    sp, fp, #4	        @ Beginning termination
	pop	    {fp, pc}
