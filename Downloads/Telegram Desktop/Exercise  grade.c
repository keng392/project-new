	#include<stdio.h>
	#include<conio.h>
	char Grade(float avg)
{
	  char grade;
	  	if(avg>=50 && avg<65)	
		grade='E';
	if(avg>=65 && avg<75)
		grade='D';
	if(avg>=75 && avg<85)
		grade='C';
	if(avg>=85 && avg<95)
		grade='B';
	if(avg>=95 && avg<=100)
		grade='A';
	return(grade);	
	}
	int main () 
	{		
		float avg;
		char grade;
		printf("Enter average=");scanf("%f",&avg);
		grade=Grade(avg);
		printf("Enter is grade =%c\n",grade);
		return 0;
	}
