/*******************************************************
*		Problem Name:			
*		Problem ID:				
*		Occassion:				_ Contest _ _ _
*
*		Algorithm:				
*		Special Case:			
*		Judge Status:			
*		Author:					Atiqur Rahman
*		Descriptions:			This program parsed rs url
								
*******************************************************/
//#include <iostream>
#include <cstdio>
//#include <cmath>
#include <cstring>
using namespace std;

int StrIndexLast(char *str1, char *str2);
bool strbegins(char *str1, char *str2);

int main(int argc, char *argv[]) {
	char *str1 = "action=\"", line[3000], *res;
	int n, i;

	if (argc <2) {
		puts("No first argument specified.");
		return 1;
	}

	if (freopen(argv[1], "r", stdin) == NULL) {
		puts("Error opening file.");
		return 1;
	}
	
	//char lincp[1000];

	while (gets(line)) {
		if (line[0] == NULL)
			continue;
		//strcpy(lincp, line);
		//printf("Line: [%s]\n", line);
		res = strstr(line, str1);
		if (res) {
			//printf("Match in line [%s]\n", line);
			n = StrIndexLast(str1, line);
			//line[n-1] = 'T';
			//printf("Changed str [%s]\n", line);

			// Set NULL in next double quote
			for (i=n; i<strlen(line);i++)
				if (line[i]=='\"')
					break;
			line[i] = NULL;
			printf("RS Server URL:\n%s\n", &line[n]);

			break;
		}
	}

	return 0;
}

int StrIndexLast(char *str1, char *str2) {
	int i;
	for (i=0; i<strlen(str2)-strlen(str1); i++) {
	//	printf("Comparing string %s with %s\n", str1, &str2[i]);
		if (strbegins(str1, &str2[i])) {
			return (i+strlen(str1));
		}
	}
	return 0;
}

bool strbegins(char *str1, char *str2) {
	char *newstr = new char[strlen(str2)+1];
	strcpy(newstr, str2);
	if (strlen(str2) > strlen(str1)) {
		newstr[strlen(str1)] = NULL;
		if (!strcmp(str1, newstr))
			return true;
	}
	delete newstr;
	return false;
}
