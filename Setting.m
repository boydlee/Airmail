//
//  Item.m
//  ChemRef
//
//  Created by Created by Lemonadestand.com.au on 3/2/09.
//  Copyright 2009 zxZX. All rights reserved.
//

#import "Setting.h"


@implementation Setting


@synthesize _id;
@synthesize effects;
@synthesize music;
@synthesize playername;

- (void)dealloc {
	[effects release];
	[music release];
	[playername release];
	[super dealloc];
}



@end
