//
//  main.m
//  efvuctl
//
//  Created by Yoann Gini on 24/04/2014.
//  Copyright (c) 2014 iNig-Services. All rights reserved.
//

#import <ddcli/DDCommandLineInterface.h>

int main(int argc, const char * argv[])
{
	uid_t userid = getuid();
	if (setuid(0) == 0) {
		return DDCliAppRunWithDefaultClass();
	}
	else {
		printf("Must be run as root\n");
		return EXIT_FAILURE;
	}
	setuid(userid);
    return 0;}

