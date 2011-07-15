//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "HighScoresScene.h"
#import "GameMenuScene.h"
#import "Database.h"
#import "Utils.h"
#import "Level.h"

@implementation HighScoresScene
@synthesize layer = _layer;

- (id)init {
	
	if ((self = [super init])) {
		self.layer = [HighScoresLayer node];
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

@implementation HighScoresLayer

-(id) init
{
	if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
		
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		//[self authenticateLocalPlayer];
		
		CCSprite *backgroundMenuSprite = [[CCSprite alloc] initWithFile:@"highscores_bg.png"];
		backgroundMenuSprite.position = ccp(winSize.width/2, winSize.height/2);
		[backgroundMenuSprite _setZOrder:1];
		[self addChild:backgroundMenuSprite];
		
		
		// Standard method to create a button
		CCMenuItem *homeButton = [CCMenuItemImage 
											itemFromNormalImage:@"backbutton.png" selectedImage:@"backbutton_on.png" 
											target:self selector:@selector(highScoresDone)];
		
		CCMenu *starMenu = [CCMenu menuWithItems:homeButton, nil];
		starMenu.position = ccp(28,295);
		[starMenu _setZOrder:3];
		[self addChild:starMenu];
		
		
		CCMenuItem *gamecenterButton = [CCMenuItemImage 
								  itemFromNormalImage:@"gamecenter.png" selectedImage:@"gamecenter.png" 
								  target:self selector:@selector(authenticateLocalPlayer)];
		
		
		CCMenu *starMenu2 = [CCMenu menuWithItems:gamecenterButton, nil];
		starMenu2.position = ccp(453,295);
		[starMenu2 _setZOrder:3];
		//[self addChild:starMenu2];
		
				
		
		[self loadScores];
		
	}	
	return self;
}

-(void) loadScores {	
	NSMutableArray* items = [Database getAllLevels:[Utils appDelegate].database];
	NSNumber *itemCount = [items count];
	if(!items)
		return;
	
	int _top = 18;
	int _left = 300;
	for(int i = ([items count]-1); i >= 0; i--)
	{
		if(i == 9){
            _left = 101; 
            _top = 18;
        }
        
        Level *fav = [items objectAtIndex:i];
		CCLabelTTF *_label = [CCLabelTTF labelWithString:fav.score dimensions:CGSizeMake(50, 20) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:15];
		[_label setColor: ccBLACK];
		[_label _setZOrder:5];
		_label.position = ccp(_left + 94,_top);
		[self addChild:_label];
		
        NSString *lvlStr = @"Level ";
		CCLabelTTF *_label2 = [CCLabelTTF labelWithString:[lvlStr stringByAppendingString:[NSString stringWithFormat:@"%d",fav._id]] fontName:@"Helvetica" fontSize:14];
		[_label2 setColor:ccBLACK];
		[_label2 _setZOrder:5];
		_label2.position = ccp(_left,_top);
		[self addChild:_label2];
		
		_top = _top + 22;
	}	
}

- (void) authenticateLocalPlayer{
	[[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error)
	{
		if (error == nil) {
			NSLog(@"Game Center: Player Authenticated!");
			[self showLeaderboard];
		}
		else{
			NSLog(@"Game Center: Authentication Failed!");
		}
	}];
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

- (void)highScoresDone {
	[[CCDirector sharedDirector] replaceScene:[[[GameMenuScene alloc] init] autorelease]];
} 

- (void)dealloc {
	[super dealloc];
}

@end
