@ Obstacle avoidance logic for robot
@ This script primarily handles moving the sensor around (first to communicate to the 
@ user that the mode is active, then to prepare for stages, and finally to return to 
@ a neutral state) as well as running the different avoidance stages in sequence. 

.cpu 	    cortex-a53
.fpu 	    neon-fp-armv8

.equ      SERVO_PIN, 15
.equ      LEFT, 515
.equ      CENTER, 295
.equ      RIGHT, 105
.equ      ECHO, 29
.equ      OBSTACLE, 40
.equ      THRESHOLD, 70
.equ      HIGH_SPEED, 3000
.equ      MID_SPEED, 2000
.equ      LOW_SPEED, 1350

.text
.align    2
.global   obstacle_avoidance
.type     obstacle_avoidance, %function

obstacle_avoidance:
	push	  {fp, lr}	              @ Initializing
	add		  fp, sp, #4
	sub		  sp, sp, #4
  mov     r4, r0                  @ fd (used for sensor rotation)
  mov     r5, #0                  @ Move count (used in stage 1 and 3)
  mov     r6, #0                  @ Current Distance (used for course_correction)
  mov     r7, #0                  @ Previous Distance (used for course_correction)
initialize_sensor:
  @ Move sensor to left
  mov     r0, r4
  mov     r1, #SERVO_PIN
  mov     r2, #0
  mov     r3, #LEFT
  bl      pca9685PWMWrite

  @ Wait
  mov     r0, #500
  bl      delay

  @ Move sensor to center
  mov     r0, r4
  mov     r1, #SERVO_PIN
  mov     r2, #0
  mov     r3, #CENTER
  bl      pca9685PWMWrite

  @ Wait
  mov     r0, #500
  bl      delay

  @ Move sensor to right
  mov     r0, r4
  mov     r1, #SERVO_PIN
  mov     r2, #0
  mov     r3, #RIGHT
  bl      pca9685PWMWrite

  @ Wait
  mov     r0, #500
  bl      delay

  @ Move sensor to center
  mov     r0, r4
  mov     r1, #SERVO_PIN
  mov     r2, #0
  mov     r3, #CENTER
  bl      pca9685PWMWrite

  @ Start stage 0
  mov     r0, #500
  bl      delay
  bl      stage_0

  @ Move sensor to right
  mov     r0, r4
  mov     r1, #SERVO_PIN
  mov     r2, #0
  mov     r3, #RIGHT
  bl      pca9685PWMWrite

  @ Wait
  mov     r0, #300
  bl      delay
stages:
  @ Go through each stage of obstacle avoidance
  bl      stage_1
  bl      stage_2
  bl      stage_3
recenter:
  @ Stage 4: Recenter the sensor and return to neutral state
  mov     r0, r4
  mov     r1, #SERVO_PIN
  mov     r2, #0
  mov     r3, #CENTER
  bl      pca9685PWMWrite
  mov     r0, #300
  bl      delay
exit:
	sub	  	sp, fp, #4	        @ Beginning termination
	pop		  {fp, pc}
