//
//  DialogLayer.h
//  concentrate
//
//  Created by Paul Legato on 12/4/10.
//  Copyright 2010 Paul Legato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface DialogLayer : CCLayer {
	NSInvocation *callback;
}

-(id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 andLine2:(NSString *)line2 andLine3:(NSString *)line3 target:(id)callbackObj selector:(SEL)selector;
-(void) okButtonPressed:(id) sender;

@end