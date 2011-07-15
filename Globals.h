//
//  Globals.h
//
//  Created by Boydlee Pollentine on 24/04/10.
//  Copyright 2010 Lemonade Stand. All rights reserved.
//

#import <Foundation/Foundation.h>

//to call a global variable, use the line below
//[[Globals sharedInstance] setchooseAllowed:@"false"];

@interface Globals : NSObject
{
    // Place any "global" variables here
	NSString *music;
	NSString *effects;
	NSString *playerName;	
}

// message from which our instance is obtained
+ (Globals *)sharedInstance;

//getters/setters
@property(nonatomic,retain)    NSString* music;
@property(nonatomic,retain)    NSString* effects;
@property(nonatomic,retain)    NSString* playerName;

@end
