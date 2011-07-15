//
//  Item.m
//  ChemRef
//
//  Created by Created by Lemonadestand.com.au on 3/2/09.
//  Copyright 2009 zxZX. All rights reserved.
//

#import "Fav.h"


@implementation Fav


@synthesize _id;
@synthesize score_name;
@synthesize score_points;


- (void)dealloc {
	[score_name release];
	[score_points release];
	[super dealloc];
}



@end
