/*  ___   ___  ___  _   _  ___   ___   ____ ___  ____
 * / _ \ /___)/ _ \| | | |/ _ \ / _ \ / ___) _ \|    \
 *| |_| |___ | |_| | |_| | |_| | |_| ( (__| |_| | | | |
 * \___/(___/ \___/ \__  |\___/ \___(_)____)___/|_|_|_|
 *                  (____/
 * Raspberry Pi Robot Car V2.0 Lesson 3: Obstacle Avoidance
 * Tutorial URL https://osoyoo.com/?p=31599
 *
 * CopyRight www.osoyoo.com
 *
 */



 /*
 *	Joshua Soteras Editied Code
 */
#include "pca9685/pca9685.h"
#include <wiringPi.h>
#include <stdio.h>

#include <string.h>
#define PIN_BASE 300
#define MAX_PWM 4096
#define HERTZ 50

 /*
  * wiringPi C library use different GPIO pin number system from BCM pin numberwhich are often used by Python,
  * you can lookup BCM/wPi/Physical pin relation by following Linux command : gpio readall
  */
#define ENA 0				//left motor speed pin ENA connect to PCA9685 port 0
#define ENB 1				//right motor speed pin ENB connect to PCA9685 port 1
#define IN1 4				//Left motor IN1 connect to wPi pin# 4 (Physical 16,BCM GPIO 23)
#define IN2 5				//Left motor IN2 connect to wPi pin# 5 (Physical 18,BCM GPIO 24)
#define IN3 2				//right motor IN3 connect to wPi pin# 2 (Physical 13,BCM GPIO 27)
#define IN4 3				//right motor IN4 connect to wPi pin# 3 (Physical 15,BCM GPIO 22)

  //SPEEDS FOR Turning Wheels
#define SPEED 2000
#define HIGH_SPEED 3000
#define LOW_SPEED 1500

//Joshua Soteras Edit: Speed for following Leader Linearly
#define SlowGear 900
#define MidGear 900
#define HighGear 900


//Macros: HEAD MOTORS
#define SERVO_PIN 15		 //right motor speed pin ENB connect to PCA9685 port 1
#define LEFT 420			//ultrasonic sensor facing right
#define CENTER 280			//ultrasonic sensor facing front
#define RIGHT 180 //ultrasonic sensor facing left
#define TRIG 28				//wPi#28=BCM GPIO#20=Physical pin#38
#define ECHO 29				//wPi#29=BCM GPIO#21=Physical pin#40

//Joshua Soteras Edit: Obstacle Thresholds
/*
* These are the different 'distances' for the follower to take actions.
* See scaling stage in int main for more information.
*/
#define MaxThresh 40
#define midThresh  23
#define followThresh 16
#define Equalibrium  14
#define minFollowThresh 12
#define minThresh 8

//Delay of actions
#define short_delay 200
#define long_delay  300
#define extra_long_delay 400

int SL = (LEFT + CENTER) / 2;
int SR = (RIGHT + CENTER) / 2;
int sts1 = 0;
int sts2 = 0;
int sts3 = 0;
char val[3];

//Josh Soteras
//See Following Stage for more information
int L_Difference;
int C_Difference;
int R_Diffrence;
int decide;

//Joshua Soteras:  functions to move the robot
// initialize  IN1,IN2,IN3,IN4 
void setup() {
	pinMode(IN1, OUTPUT);
	pinMode(IN2, OUTPUT);
	pinMode(IN3, OUTPUT);
	pinMode(IN4, OUTPUT);
	pinMode(TRIG, OUTPUT);
	pinMode(ECHO, INPUT);

	digitalWrite(IN1, LOW);
	digitalWrite(IN2, LOW);
	digitalWrite(IN3, LOW);
	digitalWrite(IN4, LOW);
}

void go_back(int fd, int speed) {
	digitalWrite(IN1, HIGH);
	digitalWrite(IN2, LOW);
	digitalWrite(IN3, HIGH);
	digitalWrite(IN4, LOW);
	pca9685PWMWrite(fd, ENA, 0, speed);
	pca9685PWMWrite(fd, ENB, 0, speed);
}

void go_advance(int fd, int speed) {
	digitalWrite(IN1, LOW);
	digitalWrite(IN2, HIGH);
	digitalWrite(IN3, LOW);
	digitalWrite(IN4, HIGH);
	pca9685PWMWrite(fd, ENA, 0, speed);
	pca9685PWMWrite(fd, ENB, 0, speed);
}

void go_left(int fd, int left_speed, int right_speed) {
	digitalWrite(IN1, HIGH);
	digitalWrite(IN2, LOW);
	digitalWrite(IN3, LOW);
	digitalWrite(IN4, HIGH);
	pca9685PWMWrite(fd, ENA, 0, left_speed);
	pca9685PWMWrite(fd, ENB, 0, right_speed);
}

void go_right(int fd, int left_speed, int right_speed) {
	digitalWrite(IN1, LOW);
	digitalWrite(IN2, HIGH);
	digitalWrite(IN3, HIGH);
	digitalWrite(IN4, LOW);
	pca9685PWMWrite(fd, ENA, 0, left_speed);
	pca9685PWMWrite(fd, ENB, 0, right_speed);
}

void stop_car(int fd) {
	digitalWrite(IN1, LOW);
	digitalWrite(IN2, LOW);
	digitalWrite(IN3, LOW);
	digitalWrite(IN4, LOW);
	pca9685PWMWrite(fd, ENA, 0, 0);
	pca9685PWMWrite(fd, ENB, 0, 0);
}

int distance() {
	//Send trig pulse
	digitalWrite(TRIG, HIGH);
	delayMicroseconds(20);
	digitalWrite(TRIG, LOW);

	//Wait for echo start
	while (digitalRead(ECHO) == LOW);

	//Wait for echo end
	long startTime = micros();
	while (digitalRead(ECHO) == HIGH);
	long travelTime = micros() - startTime;

	//Get distance in cm
	int distance = travelTime / 58;
	if (distance == 0) distance = 1000;
	return distance;
}



int main(void)
{	
	//Regular Startup to ensure all the wiring/system is functioning
	if (wiringPiSetup() == -1) {
		printf("setup wiringPi failed!\n");
		printf("please check your setup\n");
		return -1;
	}
	setup();

	//Title
	printf("Initializing Following Robot Program C\n");

	// Setup with pinbase 300 and i2c location 0x40
	int fd = pca9685Setup(PIN_BASE, 0x40, HERTZ);

	if (fd < 0)
	{
		printf("Error in setup\n");
		return fd;
	}

	pca9685PWMWrite(fd, SERVO_PIN, 0, LEFT);
	delay(1000);
	pca9685PWMWrite(fd, SERVO_PIN, 0, CENTER);
	delay(1000);
	pca9685PWMWrite(fd, SERVO_PIN, 0, RIGHT);
	delay(1000);
	pca9685PWMWrite(fd, SERVO_PIN, 0, CENTER);
	delay(1000);


	/*
	* The outer while loop (the first while  loop) is the robot functions.
	*/
	while (1)
	{
		delay(long_delay);

		/*
		*	Problem: How to follow the leader in different speeds?
		*	Solution: Hav different thresh-holds
		*
		*	***Explanations of Variables***
		*	MaxThresh = the maximum distance that is acceptable for the follower to view and search.
		*	midThresh = lower than the max threshold, the follower will speed if this limit is surpassed.
		*	followThresh = the distance that acceptable for the follower to start moving at regular speed.
		*	Equalbrium = the distance between the leader and follower that follower stops at.
		*	minFollowThresh= lower than equalbrium, if the distance is small, then follower will lower it's speed.
		*	minThresh= the distance at which the follower is aloud to be withint the leader's readius.
		*/

		/*
		* ***SCALING STAGE***
		* Entering in the inner while loop: Following the robot (Stage 1).
		* Depeneding on the different distance's between the leader and follower, the follower will take actions to slow, speed up, or stop.
		* To start following/ enter this while loop, the leader must be in sight and the follower facing straight.
		* The loop will continue to iterate as long as the leader is withint the 'MaxThresh' that the follower can see. 
		*/
		while (distance() =< MaxThreshh) {

			//Distance is at the equalibrium: stop car; 
			if (distance() == Equalibrium) {
				printf("Leader is in sight\n");
				stop_car(fd);
			}

			//Distance for Regular Speed
			else if ((distance() > followThresh) && (distance() <= midThresh)) {
				printf("Leade in range: following normal speed.t\n");
				go_advance(fd, SlowGear);
			}

			//Distance is too far from robot:  Speed UP.
			//Status Update: inserted a delay because the follower would run into leader, speed was too high.
			else if ((distance() >= midThresh && distance() <= MaxThresh)) {
				printf("Leader too far: SPEEDING UP\n");
				go_advance(fd, HighGear);
				delay(1000);
				stop_car(fd);
			}

			//Distance is too close: Slow Down
			else if ((distance() < Equalibrium) && (distance() >= minFollowThresh)) {
				printf("Leader too close: SLOWING DOWN \n");
				go_advance(fd, SlowGear);
			}
			else if ((distance() < minFollowThresh) && (distance() >= minThresh)) {
				stop_car(fd);
				delay(long_delay);
			}

			//STATUS UPDATE: Removed because this caused actual discreptencys during physical simulation runs
			//Stopping becauase follower has gone too close to leader/object
			/*else if (distance() < minThresh) {
			* 
				printf("LEADER IS TOO CLOSE\n");
				stop_car(fd);
				delay(short_delay);

				//Backing the car up becasue it rammed into the leader/object
				go_back(fd, LOW_SPEED);
				delay(short_delay);
				stop_car(fd);
				delay(long_delay);*/
				//break;
			 //}

			delay(short_delay);	
			pca9685PWMWrite(fd, SERVO_PIN, 0, CENTER); //start looking at center
			delay(200);

		}//End of Scaling Stage

		delay(long_delay);		//Creating a delay to have time for the follower to process everything.

		int secondDistance;


		/*	
		*	***LOOKING STAGE***
		*   ANALYZING WHERE LEADER IS TO FOLLOW (Stage 2)
		*	Problem: How would the follower differentiate which object to follow if there are one or more different objects to follow.
		*	Solution: Have different integer outcomes.
		*	
		*	sts1 = 1  if there is object on its left
		*	sts2 = 3  if there is an object in the center
		*   sts3 = 5  if there is an objet on its right
		*	
		*  Depending on the sum of these variables the object will caluclate a 'deciding' action to take.
		*  these values also help determine if there is one or more objects to follow. 
		*  If the number is 4 that means there are objects in the center and to left, then the follower will decide
		*  which of the to two objects to follow dpeending on which has the least distance. Hence, the L_difference, C_difference, and R_difference
		*  comes in to play.
		* 
		*  decide = 4 --> the follower senses object to its left and center
		*  decide = 5 --> the follower senses object to its right and center
		*  decide = 9 --> the follower senses objects all around itself
		* 
		* L_diffrence the distance of object to left
		* C_difference the distance of the object to its center
		* R_difference the distance of the object to its right.
		*/
		if (distance() > MaxThresh) {

			printf("Looking for leader...\n");
			stop_car(fd);
			delay(short_delay);

			//Looking West: Left
			pca9685PWMWrite(fd, SERVO_PIN, 0, LEFT);
			delay(300);
			printf("Difference Distance: %d\n", distance());
			if (distance() <= 30)
			{
				//modified code
				L_Difference = distance();
				printf("L_Difference Distance: %d\n", L_Difference);
				//pca9685PWMWrite(fd, SERVO_PIN, 0, 375);

				sts1 = 1;
			}
			else { sts1 = 0; }

			//Looking NorthWest Angle One: Angle Closest to West
			pca9685PWMWrite(fd, SERVO_PIN, 0, 350);
			delay(300);
			if (distance() <= 30 && sts1 != 1)
			{
				//modified code
				L_Difference = distance();
				printf("L_Difference Distance: %d\n", L_Difference);
				//pca9685PWMWrite(fd, SERVO_PIN, 0, 375);

				sts1 = 1;
			}

			//Looking NorthWest Angle Two: Angle Closes to North Center
			pca9685PWMWrite(fd, SERVO_PIN, 0, 310);
			delay(300);
			if (distance() <= 30 && sts1 != 1)
			{
				L_Difference = distance();
				printf("L_Difference Distance: %d\n", L_Difference);
				
				sts1 = 1;
			}

			//Looking North Center
			pca9685PWMWrite(fd, SERVO_PIN, 0, CENTER);
			delay(300);
			if (distance() <= 15) {
				printf("C_Difference Distance: %d\n", C_Difference);
				C_Difference = distance();
				sts2 = 3;
			}
			else { sts2 = 0; }

			//Looking East: Right
			pca9685PWMWrite(fd, SERVO_PIN, 0, RIGHT);
			delay(300);
			if (distance() <= 30) {
				printf("R_Difference Distance: %d\n", R_Diffrence);
				R_Diffrence = distance();
				sts3 = 5;
			}
			else { sts3 = 0; }

			//Looking North-East Angle One: Angle closest to East
			pca9685PWMWrite(fd, SERVO_PIN, 0, 225);
			delay(300);
			if (distance() <= 30 && sts3 != 5) {
				printf("R_Difference Distance: %d\n", R_Diffrence);
				R_Diffrence = distance();
				sts3 = 5;
			}
			

			//Looking North-East Angle Two: Angle Closest to North
			pca9685PWMWrite(fd, SERVO_PIN, 0, 250);
			delay(300);
			if (distance() <= 30 && sts3 != 5) {
				printf("R_Difference Distance: %d\n", R_Diffrence);
				R_Diffrence = distance();
				sts3 = 5;
			}


			//Adding All Variables to decide which object to turn/Follow
			int decide = sts1 + sts2 + sts3;

		
			//The logic earlier stated
			//deciding which object to follow based on the distance of which object is closest to it
			if (decide == 4) {
				if (L_Difference > C_Difference) { decide = 3; } //look straight if front is more closter than left
			}
			else if (decide == 8) {
				if (R_Diffrence > C_Difference) { decide = 3; }	//Looking Straight the center object is closer than the right
			}
			else if (decide == 9) {	
				if (L_Difference > C_Difference && R_Diffrence > C_Difference) {
					decide = 3; //straight
				}
				else if (L_Difference < C_Difference && L_Difference < R_Diffrence) {
					decide == 4; //sharp right 
				}
				else if (R_Diffrence < C_Difference && L_Difference > R_Diffrence) {
					decide == 8; //sharp right turn
				}
			}


			//Results of Deciding
			if (decide == 1) {
				printf("1 slight left\n");
				go_left(fd, SPEED, 0);
				delay(150);
				stop_car(fd);
				delay(short_delay);
			
			}

			if (decide == 5) {
				printf("5 slight right\n");
				go_right(fd, 0, SPEED);
				delay(150);
				stop_car(fd);
				delay(short_delay);
				
			}

			if (decide == 4) {
				printf("4 sharp left \n");
				go_left(fd, HIGH_SPEED, LOW_SPEED);
				delay(long_delay);
				stop_car(fd);
				delay(short_delay);
			}

			if (decide == 8) {
				printf("8 sharp right\n");
				go_right(fd, LOW_SPEED, HIGH_SPEED);
				delay(long_delay);
				stop_car(fd);
				delay(short_delay);
			}

			if (decide == 3) {
				delay(long_delay);
				stop_car(fd);
				delay(short_delay);

			}

			pca9685PWMWrite(fd, SERVO_PIN, 0, CENTER);
			delay(300);

		}//End of Looking Stage

	}//end of while loop

	return 0;
}

