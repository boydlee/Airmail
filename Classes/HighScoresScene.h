//
//  HighScoresScene.h
//  The AntiSanta
//
//  Created by Boydlee Pollentine on 2/12/10.
//  Copyright 2010 Boydlee Pollentine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
#import "Utils.h"
#import "cocos2d.h"
#import "Globals.h"

@interface HighScoresLayer : CCColorLayer<GKLeaderboardViewControllerDelegate>{

}
UIViewController *tempVC;
- (void)showLeaderboard;

@end

@interface HighScoresScene : CCScene {
	HighScoresLayer *_layer;
}
@property (nonatomic, retain) HighScoresLayer *layer;

@end
