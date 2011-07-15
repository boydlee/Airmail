//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "GameMenuScene.h"
#import "HighScoresScene.h"
#import "LevelSelectScene.h"
#import "InstructionsScene.h";
#import "SimpleAudioEngine.h"
#import "Setting.h"
#import "Database.h"

@implementation GameMenuScene
@synthesize layer = _layer;

- (id)init {
	
	if ((self = [super init])) {
		self.layer = [GameMenuLayer node];
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

@implementation GameMenuLayer
@synthesize label = _label;

-(id) init
{
	if( (self=[super init] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *backgroundMenuSprite = [[CCSprite alloc] initWithFile:@"menu_bg.png"];
		backgroundMenuSprite.position = ccp(winSize.width/2, winSize.height/2);
		[backgroundMenuSprite _setZOrder:1];
		[self addChild:backgroundMenuSprite];
		
		if([[Globals sharedInstance] playerName] == nil)
		{
		 NSMutableArray* items = [Database getSettings:[Utils appDelegate].database];
		 for(int i = ([items count]-1); i >= 0; i--)
		 {
			Setting *item = [items objectAtIndex:i];
			[[Globals sharedInstance] setPlayerName:item.playername];
			[[Globals sharedInstance] setEffects:item.effects];
			[[Globals sharedInstance] setMusic: item.music];
		 }
		}
		
		
		// Standard method to create a button
		CCMenuItem *instructionsMenuItem = [CCMenuItemImage 
										  itemFromNormalImage:@"instructions_menu.png" selectedImage:@"instructions_menu_over.png" 
										  target:self selector:@selector(instructionsStart)];
		instructionsMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 105);
		
		// Standard method to create a button
		CCMenuItem *highScoresMenuItem = [CCMenuItemImage 
									itemFromNormalImage:@"highscore_menu.png" selectedImage:@"highscore_menu_over.png" 
									target:self selector:@selector(highScoresStart)];
		highScoresMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 45);
		
		
		// Standard method to create a button
		CCMenuItem *gameStartMenuItem = [CCMenuItemImage 
										  itemFromNormalImage:@"play_menu.png" selectedImage:@"play_menu_over.png" 
										  target:self selector:@selector(gameStart)];
		gameStartMenuItem.position = ccp(winSize.width/2, winSize.height/2 + 15);
		
		starMenu = [CCMenu menuWithItems:highScoresMenuItem, gameStartMenuItem, instructionsMenuItem, nil];
		starMenu.position = CGPointZero;
		[starMenu _setZOrder:3];
		[self addChild:starMenu];
        
        
		// Standard method to create a button
		/*CCMenuItem *updateMenuItem = [CCMenuItemImage 
                                         itemFromNormalImage:@"upgrade.png" selectedImage:@"upgrade.png" 
                                         target:self selector:@selector(upgradeLink)];
		updateMenuItem.position = ccp(winSize.width/2 + 170, winSize.height/2 + 95);
		
		starMenu2 = [CCMenu menuWithItems: updateMenuItem, nil];
		starMenu2.position = CGPointZero;
		[starMenu2 _setZOrder:3];
		[self addChild:starMenu2];*/
		
		
		// Initialize arrays
		_targets = [[NSMutableArray alloc] init];
		
		// Call game logic about every second
		[self schedule:@selector(gameLogic:) interval:1.8];
		
		// Start up the background music
        if([[Globals sharedInstance] music] == @"NO" ){
            [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        }
        else
        {
            [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"AirRaceLoop.mp3"];
            
        }
        
	}	
	return self;
}

- (void)upgradeLink {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://lemonadestand.com.au/apps/index.php?redir=airmail-lite"]];
}

- (void)playSoundEffect {
	[[SimpleAudioEngine sharedEngine] playEffect:@"clickon.mp3"];
}

- (void)gameStart {
	[self playSoundEffect];
	[[CCDirector sharedDirector] replaceScene:[[[LevelSelectScene alloc] init] autorelease]];
}

- (void)highScoresStart {
	[self playSoundEffect];
	[[CCDirector sharedDirector] replaceScene:[[[HighScoresScene alloc] init] autorelease]];
}

-(void)instructionsStart {
	[self playSoundEffect];
	[[CCDirector sharedDirector] replaceScene:[[[InstructionsScene alloc] init] autorelease]];}


-(CCSprite*)randomSprite:(int)randomInt {
	switch (randomInt)
	{
		case 0:
			{
			CCSprite *target = [CCSprite spriteWithFile:@"package1.png" rect:CGRectMake(0, 0, 25, 37)];
			return target;
			}
			break;
			
		case 1:
			{
			CCSprite *target = [CCSprite spriteWithFile:@"package2.png" rect:CGRectMake(0, 0, 35, 52)];
			return target;
			}
			break;
			
		default:
			{	
			CCSprite *target = [CCSprite spriteWithFile:@"package1.png" rect:CGRectMake(0, 0, 25, 37)];
			return target;
			}
			break;
	}
}

-(void)addTarget {
	int r = rand() % 2;
	CCSprite *target = [self randomSprite:r];
	[target _setZOrder:2];
	
	// Determine where to spawn the target along the Y axis
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	int minY = target.contentSize.width/2;
	int maxY = winSize.width - target.contentSize.width/2;
	int rangeY = maxY - minY /2;
	int actualY = (arc4random() % rangeY) + minY;
	
	// Create the target slightly off-screen along the right edge,
	// and along a random position along the Y axis as calculated above
	target.position = ccp(actualY,winSize.width + (target.contentSize.width/2));
	[self addChild:target];
	
	// Determine speed of the target
	int minDuration = 4.0;
	int maxDuration = 6.0;
	int rangeDuration = maxDuration - minDuration;
	int actualDuration = (arc4random() % rangeDuration) + minDuration;
	
	// Create the actions
	id actionMove = [CCMoveTo actionWithDuration:actualDuration position:ccp(actualY, -target.contentSize.height/2)];
	id actionMoveDone = [CCCallFuncN actionWithTarget:self selector:@selector(spriteMoveFinished:)];
	[target runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
	CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-4.0];
	CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
	CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:4.0];
	CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
	[target runAction:[CCRepeatForever actionWithAction:rotSeq]];      
	
	// Add to targets array
	target.tag = 1;
	[_targets addObject:target];
	
}

- (void) showLeaderboard
{
	tempVC =[[UIViewController alloc] init];
	
	GKLeaderboardViewController *leaderboardController = [[[GKLeaderboardViewController alloc] init] autorelease];
	if (leaderboardController != nil)
	{
		leaderboardController.leaderboardDelegate = self;
		[[[CCDirector sharedDirector] openGLView] addSubview:tempVC.view];
		[tempVC presentModalViewController:leaderboardController animated: YES];
	}
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	[tempVC dismissModalViewControllerAnimated:YES];
	[tempVC.view removeFromSuperview];
}	



-(void)spriteMoveFinished:(id)sender {
	CCSprite *sprite = (CCSprite *)sender;
	[self removeChild:sprite cleanup:YES];
	[_targets removeObject:sprite];
}


-(void)gameLogic:(ccTime)dt {
	[self addTarget];
}


- (void)dealloc {
	[_targets release];
	_targets = nil;
	
	[super dealloc];
}

@end
