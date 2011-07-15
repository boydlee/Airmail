//
//  GameMenuScene.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//
#import <GameKit/GameKit.h>
#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Globals.h"

@interface GameMenuLayer : CCLayer<GKLeaderboardViewControllerDelegate>{
	CCLabelTTF *_label;
	CCMenu *starMenu;
	CCMenu *starMenu2;
	NSMutableArray *_targets;
	UIViewController *tempVC;
}

@property (nonatomic, retain) CCLabelTTF *label;
-(CCSprite*)randomSprite:(int)randomInt;
- (void)showLeaderboard;
- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController;

@end

@interface GameMenuScene : CCScene {
	GameMenuLayer *_layer;
}

@property (nonatomic, retain) GameMenuLayer *layer;

@end
