#include<antheader.h>

using namespace std;

int main ()

{
	int id,menu;
	 
	string  name ,gender, phone;

	start:
	
	cout << "School management system "	<< endl;
	cout << "-------------------------" << endl;
	
	cout << "1.Student                " << endl;
	cout << "2.Teacher                " << endl;
	cout << "-------------------------" << endl;
	foreColor (4);
	cout << "=>choose:";
	cin  >> menu;
	cout << "-------------------------" << endl;
	
	switch (menu)
	{
		case 1:
			cout << "please enter student information" << endl;
			cout <<  "-------------------------------" << endl;
			cout << "Enter id      : ";
		    cin  >> id; fflush(stdin);
		    cout << "Enter name    : ";
		    cin  >> name; fflush(stdin);
		    cout << "Enter gender  : ";
		    cin  >> gender; fflush(stdin);
		    cout << "Enter phone   : ";
			cin  >> phone; fflush(stdin);
			
			cout << "-------------------------------" << endl; fflush(stdin);
			cout << "ID            : " << id << endl; //fflush(stdin);
			cout << "Name          : " << name << endl; //fflush(stdin);
			cout << "Gender        : " << gender << endl; //fflush(stdin);
			cout << "Phone         : " << phone  << endl; //fflush(stdin);
			
			cout << "-------------------------------" << endl;
			
			getch();
			system ("cls");
			goto start;       
			break;
}
		//	case 2;
		//	break;
}