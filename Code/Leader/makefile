LeaderProtocol: leader.o obstacle_avoidance.o stage_0.o stage_1.o stage_2.o stage_3.o pca9685.o -lwiringPi -lpthread 
	gcc -o LeaderProtocol leader.o obstacle_avoidance.o stage_0.o stage_1.o stage_2.o stage_3.o pca9685.o -lwiringPi -lpthread
 
leader.o: leader.c
	gcc -c leader.c
	
pca9685.o: pca9685/pca9685.c
	gcc -c pca9685/pca9685.c

obstacle_avoidance.o: obstacle_avoidance.s
	gcc -c obstacle_avoidance.s

stage_0.o: stage_0.s
	gcc -c stage_0.s

stage_1.o: stage_1.s
	gcc -c stage_1.s

stage_2.o: stage_2.s
	gcc -c stage_2.s

stage_3.o: stage_3.s
	gcc -c stage_3.s
	
clean:
	-rm *.o
