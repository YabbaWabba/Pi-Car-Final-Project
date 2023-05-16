/*  
 * Final Project Leader (Based on Lesson 4 code written by Osoyoo)
 * By Parham Gholami and Bradley Khang Tran
 */
#include<stdio.h>	//printf
#include<string.h> //memset
#include<stdlib.h> //exit(0);
#include<stdbool.h> //true-false flags
#include <pthread.h>
#include<arpa/inet.h>
#include<sys/socket.h>
#include <unistd.h>
#include "pca9685/pca9685.h"
#include <wiringPi.h>
#include <signal.h>
#define PIN_BASE 300
#define MAX_PWM 4096
#define HERTZ 50
int fd;
#define BUFLEN 512	//Max length of buffer
#define PORT 8888	//The port on which to listen for incoming data
/*
 * wiringPi C library use different GPIO pin number system from BCM pin numberwhich are often used by Python, 
 * you can lookup BCM/wPi/Physical pin relation by following Linux command : gpio readall
 */
//define L298N control pins in wPi system
#define ENA 0  //ENA connect to PCA9685 port 0
#define ENB 1  //ENB connect to PCA9685 port 1
#define IN1 4  //IN1 connect to wPi pin# 4 (Physical 16,BCM GPIO 23)
#define IN2 5  //IN2 connect to wPi pin# 5 (Physical 18,BCM GPIO 24)
#define IN3 2  //IN3 connect to wPi pin# 2 (Physical 13,BCM GPIO 27)
#define IN4 3  //IN4 connect to wPi pin# 3 (Physical 15,BCM GPIO 22)

//define IR tracking sensor wPi pin#
#define sensor1 21 // No.1 sensor from far left to wPi#21 Physical pin#29
#define sensor2 22 // No.2 sensor from left to wPi#22 Physical pin#31
#define sensor3 23 // middle sensor to wPi#23 Physical pin#33
#define sensor4 24 // No.2 sensor from right to wPi#24 Physical pin#35
#define sensor5 25 // No.1 sensor from far  right to wPi#25 Physical pin#37
char val[5]; //sensor value array

// Obstacle Avoidance
#define SERVO_PIN 15  //right motor speed pin ENB connect to PCA9685 port 1
#define LEFT 515 //ultrasonic sensor facing right
#define CENTER 295 //ultrasonic sensor facing front
#define RIGHT 105 //ultrasonic sensor facing left
#define TRIG 28 //wPi#28=BCM GPIO#20=Physical pin#38
#define ECHO 29 //wPi#29=BCM GPIO#21=Physical pin#40
#define OBSTACLE 40
#define THRESHOLD 70
bool oa_active = false;
// Acceleration
#define high_speed 3000  // Max pulse length out of 4096
#define mid_speed  2000  // Max pulse length out of 4096
#define low_speed  1350  // Max pulse length out of 4096

int obstacle_avoidance(int fd);

void start_oa(void){
	// obstacle avoidance is done, set the flag to false
	obstacle_avoidance(fd);
	oa_active = false;
}

void setup(){
	pinMode(IN1,OUTPUT);
	pinMode(IN2,OUTPUT);
	pinMode(IN3,OUTPUT);
	pinMode(IN4,OUTPUT);
	pinMode(sensor1,INPUT);
	pinMode(sensor2,INPUT);
	pinMode(sensor3,INPUT);
	pinMode(sensor4,INPUT);
	pinMode(sensor5,INPUT);
	pinMode(TRIG,OUTPUT);
	pinMode(ECHO,INPUT); 

	digitalWrite(IN1,LOW);
	digitalWrite(IN2,LOW);
	digitalWrite(IN3,LOW);
	digitalWrite(IN4,LOW);
}
void go_Back(int fd,int l_speed,int r_speed){
	digitalWrite(IN1,HIGH);
	digitalWrite(IN2,LOW);
	digitalWrite(IN3,HIGH);
	digitalWrite(IN4,LOW); 
	pca9685PWMWrite(fd, ENA, 0, r_speed);
	pca9685PWMWrite(fd, ENB, 0, l_speed);
}
void go_Advance(int fd,int l_speed,int r_speed){
	digitalWrite(IN1,LOW);
	digitalWrite(IN2,HIGH);
	digitalWrite(IN3,LOW);
	digitalWrite(IN4,HIGH); 
	pca9685PWMWrite(fd, ENA, 0, r_speed);
	pca9685PWMWrite(fd, ENB, 0, l_speed);
}
void go_Left(int fd,int l_speed,int r_speed){
	digitalWrite(IN1,HIGH);
	digitalWrite(IN2,LOW);
	digitalWrite(IN3,LOW);
	digitalWrite(IN4,HIGH); 
	pca9685PWMWrite(fd, ENA, 0, l_speed);
	pca9685PWMWrite(fd, ENB, 0, r_speed);
}
void go_Right(int fd,int l_speed,int r_speed){
	digitalWrite(IN1,LOW);
	digitalWrite(IN2,HIGH);
	digitalWrite(IN3,HIGH);
	digitalWrite(IN4,LOW); 
	pca9685PWMWrite(fd, ENA, 0, l_speed);
	pca9685PWMWrite(fd, ENB, 0, r_speed);
}
void stop_car(int fd){
	digitalWrite(IN1,LOW);
	digitalWrite(IN2,LOW);
	digitalWrite(IN3,LOW);
	digitalWrite(IN4,LOW); 
	pca9685PWMWrite(fd, ENA, 0, 0);
	pca9685PWMWrite(fd, ENB, 0, 0);
}

void step_forward(int steps){
	for(int i = 0; i < steps; i++){
		go_Advance(fd,low_speed,low_speed);
		delay(200);
		stop_car( fd);
		delay(1600);
	}
}

void course_correct(int current, int previous){
	// While the robot is moving forward, we also check to make sure it's staying relatively parallel to the obstacle
	// We will compare the current distance of the robot to the obstacle with the previous distance
	// If it's getting closer, we'll rotate away slightly from the obstacle (left). If it's moving further away, we'll rotate slightly towards the obstacle (right).
	if(current > previous && previous != 0){
		//printf("Adjust right\n");
		go_Right( fd,1500,0);
		delay(150);
	}
	else if (current < previous){
		//printf("Adjust left\n");
		go_Left( fd,0,1500);
		delay(150);
	}
}

// ctrl-C key event handler
void my_handler(int s){
	stop_car( fd);
	printf("Ctrl C detected %d\n",s);
	exit(1); 
}

void die(char *s)
{
	perror(s);
	exit(1);
}

int distance() {
	//Send trig pulse
	digitalWrite(TRIG, HIGH);
	delayMicroseconds(20);
	digitalWrite(TRIG, LOW);

	//Wait for echo start
	while(digitalRead(ECHO) == LOW);

	//Wait for echo end
	long startTime = micros();
	while(digitalRead(ECHO) == HIGH);
	long travelTime = micros() - startTime;

	//Get distance in cm
	int distance = travelTime / 58;
	if (distance==0) distance=1000;
	return distance;
}


int main(void)
{
    //set up wiringPi GPIO 
    if(wiringPiSetup()==-1){
        printf("setup wiringPi failed!\n");
        printf("please check your setup\n");
        return -1;
    }

    //set up GPIO pin mode
	setup();

  	// Setup thread
  	pthread_t oa_thread;
 
	// Setup PCA9685 with pinbase 300 and i2c location 0x40
	fd = pca9685Setup(PIN_BASE, 0x40, HERTZ);
	if (fd < 0)
	{
		printf("Error in setup\n");
		return fd;
	}

   	// following 5 lines define ctrl-C events
   	struct sigaction sigIntHandler;
   	sigIntHandler.sa_handler = my_handler;
   	sigemptyset(&sigIntHandler.sa_mask);
   	sigIntHandler.sa_flags = 0;
   	sigaction(SIGINT, &sigIntHandler, NULL);

    //following 20 lines set up Socket to receive UDP
	struct sockaddr_in si_me, si_other;
	int s, i, slen = sizeof(si_other) , recv_len;
	char buf[BUFLEN];
	//create a UDP socket
	if ((s=socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) == -1)
	{
		die("socket");
	}
	
	// zero out the structure
	memset((char *) &si_me, 0, sizeof(si_me));
	si_me.sin_family = AF_INET;
	si_me.sin_port = htons(PORT);
	si_me.sin_addr.s_addr = htonl(INADDR_ANY);
	
	//bind socket to port
	if( bind(s , (struct sockaddr*)&si_me, sizeof(si_me) ) == -1)
	{
		die("bind");
	}
	
	int initSpd = 2000;		// Initial Speed [Max Speed is 4096]

	//keep listening for data
	while(1)
	{
		printf("Waiting for APP command...\n");
		fflush(stdout);
		
		//try to receive some data, this is a blocking call
		if ((recv_len = recvfrom(s, buf, BUFLEN, 0, (struct sockaddr *) &si_other, &slen)) == -1)
		{
			die("recvfrom()");
		}
		
		if(buf[0] != 'O' && oa_active){
			// If obstacle avoidance is active, we don't want any additional inputs to interfere with that process, unless the user
			// is pressing the "obstacle" button and attempting to cancel obstacle avoidance.
			printf("Command ignored, obstacle avoidance is active!\n");
			continue;
		}

		switch(buf[0])
		{
			case 'F':
				initSpd = high_speed;
				printf("Speed increased to 3000 pulse length\n");
				//printf("Current Speed: %d\n", initSpd);
				break;	    

			case 'G':
				initSpd = low_speed;
				printf("Speed decreased to 1350 pulse length\n");
				//printf("Current Speed: %d\n", initSpd);
				break;

			case 'H':
				initSpd = mid_speed;
				printf("Speed changed to initial 2000 pulse length\n");
				//printf("Current Spdd: %d\n", initSpd);
				break;

			case 'A':
				go_Advance( fd,initSpd,initSpd);
				//printf("Advance Current Speed: %d\n", initSpd);
				break;

			case 'B':
				go_Back( fd,initSpd,initSpd);
				//printf("Reverse Current Speed: %d\n", initSpd);
				break;

			case 'L':
				go_Left( fd,0,low_speed);
				break;

			case 'R':
				go_Right( fd,low_speed,0);
				break;

			case 'O':	;
				if(!oa_active){
					// If OA isn't active currently, we'll start an OA thread and mark the OA flag as true
					pthread_create(&oa_thread, NULL, start_oa, NULL);
					printf("Obstacle avoidance initiated\n");
					oa_active = true;
				}
				else{
					// If it is active, then we will terminate the thread and mark the OA flag as false
					pthread_cancel(oa_thread);
					printf("Obstacle avoidance cancelled\n");
					oa_active = false;
				}
				break;
			case 'E':
				stop_car( fd);
				break;
		}		
	}
	close(s);
	return 0;
}

