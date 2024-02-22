#include<stdio.h>
#include<conio.h>
float total(float c )
{
	float total,discount;
		if(c>=1500) 
		 if(c>=3500)
	    discount=c*0.12;
	    else
		discount=c*0.07;   
	 else	
		discount=c*0.05;
	total=c-discount;	                             
    return(total);
}
    int main ()
 {   
    float price,amount;
    printf("Enter price =");scanf("%f",&price);
    amount=total(price);
    printf("this is =%.2f\n",amount);
return 0;
}

   
