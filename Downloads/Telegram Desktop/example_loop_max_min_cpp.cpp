#include<iostream>
 
 using namespace std;
 
 int  main()
 {
 	int n;
	int max, min;

 	cout<<"max,min,Elements In Array"<<endl;
 	cout<<"....................."<<endl;
 	cout<<"Enter Elements :" ;
 	cin >>n; fflush(stdin);
 	cout<<endl;
 	
 	int numbers[n];
 	for (int i=0;i<n;i++)
 	{
 	cout<<"Enter number[" << i <<"] : ";
	cin >>numbers[i];fflush(stdin);	
	}
	cout<<endl;
	max=numbers[0];
    cout<<"Max elements : ";
    for(int i=0;i<n;i++)
    {
   	if(numbers[i]>max)
   	   {
   	   	max = numbers[i];
	   }
	} 
	cout <<"The maximum number is:"<<max<<endl;   

	min=numbers[0];
    cout<<"Min elements : ";
    for(int i=0;i<n;i++)
    {
   	if(numbers[i]<min)
  	   {
    	min = numbers[i];

	   } 
	} 
	cout <<"The minimum number is:"<<min<<endl; 
}