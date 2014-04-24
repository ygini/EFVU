//
//  main.m
//  efvuctl
//
//  Created by Yoann Gini on 24/04/2014.
//  Copyright (c) 2014 iNig-Services. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EFVUCoreStorage.h>

int main(int argc, const char * argv[])
{

	@autoreleasepool {
		
		if ([EFVUCoreStorage volumeIdentifierIsAnEncryptedDisk:@"/Volumes/EFVU"]) {
			NSLog(@"YES");
		}
		else {
			NSLog(@"NO");
		}

	    
	}
    return 0;
}

