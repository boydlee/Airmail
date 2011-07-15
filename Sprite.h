//
//  Item.h
//  ChemRef
//
//  Created by Created by Lemonadestand.com.au on 3/2/09.
//  Copyright 2009 zxZX. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface Sprite : NSObject {
	int _id;
	int height;
	int width;
	int level_id;
	NSString* type;
	int x;
	int y;
	NSString* imagefile;
}

@property(nonatomic, assign)   int _id;
@property(nonatomic, assign)   int height;
@property(nonatomic, assign)   int width;
@property(nonatomic, assign)   int level_id;
@property(nonatomic,retain)    NSString* type;
@property(nonatomic,retain)    NSString* imagefile;
@property(nonatomic, assign)	int y;
@property(nonatomic, assign)	int x;

@end
