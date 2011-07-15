//
//  DialogLayer.m
//  concentrate
//
//  Created by Paul Legato on 12/4/10.
//  Copyright 2010 Paul Legato. All rights reserved.
//

#import "DialogLayer.h"
#import "Globals.h"
#import "SimpleAudioEngine.h"

#define DIALOG_FONT @"coopheavy.fnt"

@implementation DialogLayer
-(id) initWithHeader:(NSString *)header andLine1:(NSString *)line1 andLine2:(NSString *)line2 andLine3:(NSString *)line3 target:(id)callbackObj selector:(SEL)selector
{
	if((self=[super init])) {
		
		NSMethodSignature *sig = [[callbackObj class] instanceMethodSignatureForSelector:selector];
		callback = [NSInvocation invocationWithMethodSignature:sig];
		[callback setTarget:callbackObj];
		[callback setSelector:selector];
		[callback retain];
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		
		CCSprite *background = [CCSprite node];
		[background initWithFile:@"dialog.png"];
		[background setPosition:ccp(screenSize.width / 2, screenSize.height / 2)];
		[self addChild:background z:-1];
		
		CCLabelBMFont *headerShadow = [CCLabelBMFont labelWithString:header fntFile:DIALOG_FONT];
		headerShadow.color = ccGRAY;
		headerShadow.opacity = 127;
		[headerShadow setPosition:ccp(243, 262)];
		[self addChild:headerShadow];
		
		CCLabelBMFont *headerLabel = [CCLabelBMFont labelWithString:header fntFile:DIALOG_FONT];
		headerLabel.color = ccBLACK;
		[headerLabel setPosition:ccp(240, 265)];
		[self addChild:headerLabel];
		
		//////////////////
		
		CCLabelBMFont *line1Label = [CCLabelBMFont labelWithString:line1 fntFile:DIALOG_FONT];
		line1Label.color = ccBLACK;
		line1Label.scale = 0.84f;
		[line1Label setPosition:ccp(240, 200)];
		[self addChild:line1Label];
		
		CCLabelBMFont *line2Label = [CCLabelBMFont labelWithString:line2 fntFile:DIALOG_FONT];
		line2Label.color = ccBLACK;
		line2Label.scale = 0.84f;
		[line2Label setPosition:ccp(240, 160)];
		[self addChild:line2Label];
		
		CCLabelBMFont *line3Label = [CCLabelBMFont labelWithString:line3 fntFile:DIALOG_FONT];
		line3Label.color = ccBLACK;
		line3Label.scale = 0.84f;
		[line3Label setPosition:ccp(240, 120)];
		[self addChild:line3Label];
		
		CCMenuItemImage *okButton = [CCMenuItemImage itemFromNormalImage:@"okay.png" selectedImage:@"okay.png" target:self selector:@selector(okButtonPressed:)];
		[okButton setPosition:ccp(0, 60)];
		
		CCMenu *menu = [CCMenu menuWithItems: okButton, nil];
		menu.position = ccp(240,0);
		[self addChild:menu];
	}
	return self;
}

-(void) okButtonPressed:(id) sender
{
	[[SimpleAudioEngine sharedEngine] playEffect:@"clickon.mp3"];	
	[self removeFromParentAndCleanup:YES];
	//[callback invoke];
}

-(void) dealloc
{
	[callback release];
	[super dealloc];
}
@end