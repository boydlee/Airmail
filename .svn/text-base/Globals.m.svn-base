//
//  Globals.m
//
//  Created by Boydlee Pollentine on 24/04/10.
//  Copyright 2010 Lemonade Stand. All rights reserved.
//

#import "Globals.h"


@implementation Globals

@synthesize music, effects, playerName;

+ (Globals *)sharedInstance
{
    // the instance of this class is stored here
    static Globals *myInstance = nil;
	
    // check to see if an instance already exists
    if (nil == myInstance) {
        myInstance  = [[[self class] alloc] init];
        // initialize variables here
    }
    // return the instance of this class
    return myInstance;
}

@end
