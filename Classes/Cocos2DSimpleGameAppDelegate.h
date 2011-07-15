//
//  Cocos2DSimpleGameAppDelegate.h
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 11/21/10.
//  Copyright Ray Wenderlich 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"
#import <GameKit/GameKit.h>

@class RootViewController;

@interface Cocos2DSimpleGameAppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate, GKLeaderboardViewControllerDelegate, GKSessionDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
	sqlite3* database;
	Database *db;	
}

@property (nonatomic, retain) UIWindow *window;
@property sqlite3* database;

- (void)specifyStartLevel;
- (void) authenticateLocalPlayer;

@end
