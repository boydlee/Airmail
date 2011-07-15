//
//  Item.h
//  ChemRef
//
//  Created by Created by Lemonadestand.com.au on 3/2/09.
//  Copyright 2009 zxZX. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Setting : NSObject {
	int _id;
	NSString* effects;
	NSString* music;
	NSString* playername;
	
}

@property    int _id;
@property(nonatomic,retain)    NSString* effects;
@property(nonatomic,retain)    NSString* music;
@property(nonatomic,retain)    NSString* playername;

@end
