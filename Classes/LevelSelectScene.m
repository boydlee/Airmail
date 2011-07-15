//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "LevelSelectScene.h"
#import "GamePlayScene.h"
#import "GameMenuScene.h";
#import "SimpleAudioEngine.h"
#import "Setting.h"
#import "Database.h"
#import "Utils.h"

@implementation LevelSelectScene
@synthesize layer = _layer;

- (id)init {
	
	if ((self = [super init])) {
		self.layer = [LevelSelectLayer node];
		[self addChild:_layer];
	}
	return self;
}

- (void)dealloc {
	[_layer release];
	_layer = nil;
	[super dealloc];
}

@end

@implementation LevelSelectLayer
-(id) init
{
	if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *backgroundMenuSprite = [[CCSprite alloc] initWithFile:@"level_bg.png"];
		backgroundMenuSprite.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:backgroundMenuSprite];
		
		// Standard method to create a button
		CCMenuItem *homeButton = [CCMenuItemImage 
								  itemFromNormalImage:@"backbutton.png" selectedImage:@"backbutton_on.png" 
								  target:self selector:@selector(levelMenuDone)];
		
		
        
        CCMenu *starMenu = [CCMenu menuWithItems:homeButton, nil];
		starMenu.position = ccp(28,295);
		[self addChild:starMenu];
		
		
		// Standard method to create a button
		CCMenuItem *sectionOneButton = [CCMenuItemImage 
								  itemFromNormalImage:@"section1.png" selectedImage:@"section1.png" 
								  target:self selector:nil];
		sectionOneButton.position = ccp(168,55);
		
		CCMenuItem *sectionTwoButton = [CCMenuItemImage 
										itemFromNormalImage:@"section2_off.png" selectedImage:@"section2.png" 
										target:self selector:@selector(changeToSectionTwo)];
		sectionTwoButton.position = ccp(308,55);
		
		section1Menu = [CCMenu menuWithItems:sectionOneButton, sectionTwoButton, nil];
		section1Menu.position = CGPointZero;
		[self addChild:section1Menu];
		
		
		// Standard method to create a button
		CCMenuItem *sectionOneButton2 = [CCMenuItemImage 
										itemFromNormalImage:@"section1_off.png" selectedImage:@"section1.png" 
										target:self selector:@selector(changeToSectionOne)];
		sectionOneButton2.position = ccp(168,55);
		
		CCMenuItem *sectionTwoButton2 = [CCMenuItemImage 
										itemFromNormalImage:@"section2.png" selectedImage:@"section2.png" 
										target:self selector:nil];
		sectionTwoButton2.position = ccp(308,55);
		
		section2Menu = [CCMenu menuWithItems:sectionOneButton2, sectionTwoButton2, nil];
		section2Menu.position = ccp(-2000, -2000);
		[self addChild:section2Menu];
	
		NSMutableArray *items = [Database getLevels:[Utils appDelegate].database];
		int _top = 228;
		int _left = 70;
		int _counter = 0;
		
		//initialize the empty menu
		levelMenu = [CCMenu menuWithItems: nil];
		levelMenu.position = CGPointZero;
		[self addChild:levelMenu];
		
		for(int i = 0; i < [items count]; i++)
		{
			Level *item = [items objectAtIndex:i];
			NSString *levelImage = @"levellocked.png";
						
			// Standard method to create a button
			CCMenuItem *gameStartMenuItem;
			
			if([item.locked isEqualToString:@"TRUE"])
			{
			  gameStartMenuItem = [CCMenuItemImage itemFromNormalImage:levelImage selectedImage:levelImage target:self selector:nil];
			  gameStartMenuItem.tag = item._id; //this needs to be the level id
			  gameStartMenuItem.position = ccp(_left, _top);
			}
			else 
			{
			  levelImage = [@"level" stringByAppendingString:[NSString stringWithFormat:@"%d", i+1]];
			  levelImage = [levelImage stringByAppendingString: @".png"];
			  gameStartMenuItem = [CCMenuItemImage itemFromNormalImage:levelImage selectedImage:levelImage target:self selector:@selector(gameStart:)];
			  gameStartMenuItem.tag = item._id; //this needs to be the level id
			  gameStartMenuItem.position = ccp(_left, _top);
			}
			
			[levelMenu addChild:gameStartMenuItem];
			
			_counter++; //increment the counter of level items
			
			if(_counter < 5) 
			{
				_left = _left + 85;
			}
			else
			{
				//restart on a new row (_top) value
				_top = _top - 70;
				_left = 70;
				_counter = 0;
			}

		}
		
	}	
	return self;
}


- (void)upgradeLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://lemonadestand.com.au/apps/index.php?redir=airmail-lite"]];
}

-(void) changeToSectionOne {
	section1Menu.position = CGPointZero;
	section2Menu.position = ccp(-2000, -2000);
	
	for (int r = ([[levelMenu children] count] - 1); r >= 0; r--) {		
		[[levelMenu children] removeObjectAtIndex:r];
	}
	
	NSMutableArray *items = [Database getLevels:[Utils appDelegate].database];
	int _top = 228;
	int _left = 70;
	int _counter = 0;
	for(int i = 0; i < [items count]; i++)
	{
		Level *item = [items objectAtIndex:i];
		NSString *levelImage = @"levellocked.png";
		
		// Standard method to create a button
		CCMenuItem *gameStartMenuItem;
		
		if([item.locked isEqualToString:@"TRUE"])
		{
			gameStartMenuItem = [CCMenuItemImage itemFromNormalImage:levelImage selectedImage:levelImage target:self selector:nil];
			gameStartMenuItem.tag = item._id; //this needs to be the level id
			gameStartMenuItem.position = ccp(_left, _top);
		}
		else 
		{
			levelImage = [@"level" stringByAppendingString:[NSString stringWithFormat:@"%d", i+1]];
			levelImage = [levelImage stringByAppendingString: @".png"];
			gameStartMenuItem = [CCMenuItemImage itemFromNormalImage:levelImage selectedImage:levelImage target:self selector:@selector(gameStart:)];
			gameStartMenuItem.tag = item._id; //this needs to be the level id
			gameStartMenuItem.position = ccp(_left, _top);
		}
		
		[levelMenu addChild:gameStartMenuItem];
		
		_counter++; //increment the counter of level items
		
		if(_counter < 5) 
		{
			_left = _left + 85;
		}
		else
		{
			//restart on a new row (_top) value
			_top = _top - 70;
			_left = 70;
			_counter = 0;
		}
		
	}
}

-(void) changeToSectionTwo {
	section2Menu.position = CGPointZero;
	section1Menu.position = ccp(-2000, -2000);
	
	for (int r = ([[levelMenu children] count] - 1); r >= 0; r--) {		
		[[levelMenu children] removeObjectAtIndex:r];
	}
	
	NSMutableArray *items = [Database getLevelsGreaterThanId:@"10" InDatabase:[Utils appDelegate].database];
	int _top = 228;
	int _left = 70;
	int _counter = 0;
						
	for(int i = 0; i < [items count]; i++)
	{
	 Level *item = [items objectAtIndex:i];
	 NSString *levelImage = @"levellocked.png";
	 
	 // Standard method to create a button
	 CCMenuItem *gameStartMenuItem;
	 
	 if([item.locked isEqualToString:@"TRUE"])
	 {
		 gameStartMenuItem = [CCMenuItemImage itemFromNormalImage:levelImage selectedImage:levelImage target:self selector:nil];
		 gameStartMenuItem.tag = item._id; //this needs to be the level id
		 gameStartMenuItem.position = ccp(_left, _top);
	 }
	 else 
	 {
		 levelImage = [@"level" stringByAppendingString:[NSString stringWithFormat:@"%d", i+1]];
		 levelImage = [levelImage stringByAppendingString: @".png"];
		 gameStartMenuItem = [CCMenuItemImage itemFromNormalImage:levelImage selectedImage:levelImage target:self selector:@selector(gameStart:)];
		 gameStartMenuItem.tag = item._id; //this needs to be the level id
		 gameStartMenuItem.position = ccp(_left, _top);
	 }
	 
	 [levelMenu addChild:gameStartMenuItem];
	 
	 _counter++; //increment the counter of level items
	 
	 if(_counter < 5) 
	 {
		 _left = _left + 85;
	 }
	 else
	 {
		 //restart on a new row (_top) value
		 _top = _top - 70;
		 _left = 70;
		 _counter = 0;
  	 }	 
   }							 
}

- (void)gameStart:(id)sender {
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	GamePlayScene *gameScene = [GamePlayScene node];
	CCMenuItem *item = (CCMenuItem*)sender;
	gameScene.layer._level = item.tag;
	[gameScene.layer loadLevelData];
	[[CCDirector sharedDirector] replaceScene:gameScene];
	
}

- (void)levelMenuDone {
	[[CCDirector sharedDirector] replaceScene:[[[GameMenuScene alloc] init] autorelease]];
}


- (void)dealloc {
	[super dealloc];
}

@end
