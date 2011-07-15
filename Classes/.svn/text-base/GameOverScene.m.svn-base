//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "GameOverScene.h"
#import "GameMenuScene.h"
#import "GamePlayScene.h"
#import "Globals.h"

@implementation GameOverScene
@synthesize layer = _layer;

- (id)init {

	if ((self = [super init])) {
		self.layer = [GameOverLayer node];
						
		[self addChild:_layer];
	}
	return self;
}

- (void)quitGame { 
	GameMenuScene *gameMenuScene = [GameMenuScene node];
	[[CCDirector sharedDirector] replaceScene:gameMenuScene];
}

- (void)playAgain { 	
	GamePlayScene *playScene = [GamePlayScene node];
	[[CCDirector sharedDirector] replaceScene:playScene];
}

- (void)dealloc {
	[_layer release];
	_layer = nil;
	[super dealloc];
}

@end

@implementation GameOverLayer
@synthesize label = _label;

-(id) init
{
	if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *backgroundMenuSprite = [[CCSprite alloc] initWithFile:@"gameover_bg.png"];
		backgroundMenuSprite.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:backgroundMenuSprite];
		
		// Standard method to create a button
		CCMenuItem *menuItem = [CCMenuItemImage 
								itemFromNormalImage:@"quitgame.png" selectedImage:@"quitgame_over.png" 
								target:self selector:@selector(gameOverMenu)];
		menuItem.position = ccp(winSize.width/2, winSize.height/2 - 80);
		
		
		// Standard method to create a button
		CCMenuItem *gameStartMenuItem = [CCMenuItemImage 
										 itemFromNormalImage:@"playagain.png" selectedImage:@"playagain_over.png" 
										 target:self selector:@selector(gameOverReplay)];
		gameStartMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 30);
		
		CCMenu *pauseMenu = [CCMenu menuWithItems: gameStartMenuItem, menuItem, nil];
		pauseMenu.position = CGPointZero;
		[self addChild:pauseMenu];
		
		
	}	
	return self;
}

- (void)gameOverMenu {
	[[CCDirector sharedDirector] replaceScene:[[[GameMenuScene alloc] init] autorelease]];	
}

- (void)gameOverReplay {
	[[CCDirector sharedDirector] replaceScene:[[[GamePlayScene alloc] init] autorelease]];	
}

- (void)dealloc {
	[_label release];
	_label = nil;
	[super dealloc];
}

@end
