/*******************************************************
*		Problem Name:			
*		Problem ID:				
*		Occassion:				_ Contest _ _ _
*
*		Algorithm:				
*		Special Case:			
*		Judge Status:			
*		Author:					Atiqur Rahman
*		Descriptions:			This program resolves Network Address for specific IP Address
								
*******************************************************/
//#include <iostream>
#include <cstdio>
//#include <cmath>
#include <cstring>
using namespace std;

int main(int argc, char *argv[]) {
	freopen("H:\\Net Workspace\\Net Confs\\Hack conf.txt", "r", stdin);
	//freopen("_out.txt", "w", stdout);

	const char* PREFIX="10.16.128.";
	char line[200], ip_add[20], cl_ip[20];
	int i,ind,j;
	bool nonzerofound=false;

	if (argc <2) {
		puts("Argument Missing!\nError");
		return 0;
	}

	ind = strlen (argv[1]);
	// drop extra zeroes in command line if any
	for (i = 0, j = 0; i<ind; i++, j++)
		if (argv[1][i] != '0' || nonzerofound) {
			cl_ip[j] = argv[1][i];
			nonzerofound = true;
		}
	cl_ip[j] = '\0';

	//printf("Query IP Address: %s%s\n", PREFIX, cl_ip);

	while (gets(line)) {
		if (line[0]) {
			// puts(line);
			// Get ip address in ip_add
			ind = 0;
			while(line[ind++] == ' ');
			for (i=0, ind--;line[ind] != ' ' && i<20  && line[ind]; ind++, i++) {
				if (line[ind] == '.')
					i = -1;
				else
					ip_add[i] = line[ind];
			}
			ip_add[i] = '\0';
			// printf("Got ip: '%s' line: %s\n", ip_add, line);
			// printf("Got ip: '%s'\n", ip_add);
			// Check ip address if it matches
			if (!strcmp(ip_add, cl_ip)) {
				// If match found output Net Address
				puts("Network Address:");
				while(line[ind++] == ' ');
				for (i=ind-1; (line[i] != ' ') && line[i]; i++)
					if (line[i] != '-')
						putchar(line[i]);
				putchar('\n');
				return 0;
			}
		}
	}
	puts("EOF!\nError");

	return 0;
}
