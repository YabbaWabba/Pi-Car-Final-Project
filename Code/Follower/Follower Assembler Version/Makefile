FollowerProtocol: Scaling.o Looking.o Important_Values.o StartUp.o  Follower.o main.o tools.o pca9685/pca9685.c -lwiringPi
	gcc -o FollowerProtocol Scaling.o Looking.o Important_Values.o StartUp.o Follower.o main.o tools.o pca9685/pca9685.c -lwiringPi

tools.o: tools.c pca9685/pca9685.c -lwiringPi
	gcc -g -c tools.c  pca9685/pca9685.c -lwiringPi
	
Scaling.o: Scaling.s
	gcc -g -c Scaling.s

Looking.o: Looking.s
	gcc -g -c Looking.s
	
Important_Values.o: Important_Values.s
	gcc -g -c Important_Values.s
	
StartUp.o: StartUp.s
	gcc -g -c StartUp.s

Follower.o: Follower.s
	gcc -g -c Follower.s
	
main.o: main.s
	gcc -g -c main.s
	
clean:
	rm -i *.o FollowerProtocol
