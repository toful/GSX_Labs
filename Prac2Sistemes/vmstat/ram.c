#include <stdio.h>
#include <unistd.h>
#include <memory.h>
#define MB 1024 * 1024

void main(){
	int counter = 0;
	while(counter < 10){
		void *p = malloc(100*MB);
		memset(p,0, 100*MB);
		sleep(1);
		counter++;
	}
}
