#include<stdio.h>
#include<conio.h>
 char  name (char H)
 {
 	char grade;
    if(H<=500)
    if(H<=1500)
    H=H*0.07;
    else
    H=H*0.05;
 	return(grade);
 }
 int main (){
  char A,discount;
  printf("Enter A=");scanf("%c",&A);
  discount=name(A);
  printf("Enter is =%c\n",discount);
  return 0; 
  }
