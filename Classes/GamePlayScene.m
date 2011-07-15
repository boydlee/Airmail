//
// cocos2d Hello World example
// http://www.cocos2d-iphone.org
//

// Import the interfaces
#import "GamePlayScene.h"
#import "SimpleAudioEngine.h"
#import "GameOverScene.h"
#import "LevelSelectScene.h"
#import "GameMenuScene.h"
#import "Database.h"
#import "Fav.h"
#import "Globals.h"
#import "Utils.h"
#import "Sprite.h"
#import "DialogLayer.h"

@implementation GamePlayScene
@synthesize layer = _layer;

- (id)init {
    if ((self = [super init])) {
		self.layer = [GamePlay node];
        [self addChild:_layer];
    }
	
	return self;
}

- (void)dealloc {
    self.layer = nil;
    [super dealloc];
}

@end


// GamePlay implementation
@implementation GamePlay

@synthesize _level;

int TARGET_BUILDING = 1;
int TARGET_BIGBUILDING = 13;
int TARGET_MAILBOX = 2;
int TARGET_MAILBOX_FULL = 0;
int TARGET_GIRDER = 3;
int TARGET_MOVINGGIRDER = 14;
int TARGET_DOWNER = 10;
int TARGET_FUSEBOX = 12;
int PROJECTILE_PACKAGE = 4;
int PROJECTILE_BOMB = 5;

int SOUND_EFFECT_PACKAGE_SCORE = 1;
int SOUND_EFFECT_BOMB_EXPLODE = 2;
int SOUND_EFFECT_BUILDING_COLLAPSE = 3;
int SOUND_EFFECT_LEVEL_COMPLETE = 4;
int SOUND_EFFECT_PACKAGE_DROP = 5;
int SOUND_EFFECT_BOMB_WHISTLE = 6;

int PARTICLE_EFFECT_MAIL_DELIVERED = 6;
int PARTICLE_EFFECT_BUILDING_COLLAPSE = 7;
int PARTICLE_EFFECT_EXPLOSION = 8;
int PARTICLE_EFFECT_WINDLEFT = 9;
int PARTICLE_EFFECT_PLANEEXPLOSION = 11;

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super initWithColor:ccc4(0,0,0,0)] )) 
	{
		//Get the dimensions of the window for calculation purposes
		winSize = [[CCDirector sharedDirector] winSize];
		
		//Initialize arrays and variables
		_points = 0;
		_packages_score = 0;
		_currently_loaded_projectile = PROJECTILE_PACKAGE;
		_paused = 0;
		
		// Enable touch events
		self.isTouchEnabled = YES;
		[[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
			
		
		//preload sound effects
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"success_sound_exploding_glass_01.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"battle003-explosion.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"orchestral_ta_da_stinger_01.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"battle047-impactgroundtargets.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"parachute_open_05.mp3"];
		
		//preload particle textures
		[[CCTextureCache sharedTextureCache] addImage:@"Particle_BuildingCrumble.png"];
		[[CCTextureCache sharedTextureCache] addImage:@"Particle_Explode.png"];
		[[CCTextureCache sharedTextureCache] addImage:@"Particle_PlaneExplode.png"];
		[[CCTextureCache sharedTextureCache] addImage:@"Particle_MailDelivered.png"];
	}
	return self;
}

- (void)loadLevelData {
	//Get the level data from sqlite db
	Level* levelData = [Database getLevel:[NSString stringWithFormat: @"%d", _level] InDatabase:[Utils appDelegate].database];
	_goal = levelData.goal;
	_bombs_remaining = levelData.bombs;
	_packages_remaining = levelData.packages;
	_time = levelData._time;
	_speed = levelData._speed;
	_currentHighScore =  [levelData.score intValue];
	_wind = levelData._wind;
	_planeY = 280;
	
	//add background image
	CCSprite *bgSprite = [[CCSprite alloc] initWithFile:levelData._background];
	bgSprite.position = ccp(winSize.width/2, winSize.height/2);
	[self addChild:bgSprite];
	
	CCSprite *floorSprite = [[CCSprite alloc] initWithFile:@"game_floor.png"];
	[floorSprite _setZOrder:2];
	floorSprite.position = ccp(240, 6);
	[self addChild:floorSprite];
	
	_targets = [[NSMutableArray alloc] init];
	_projectiles = [[NSMutableArray alloc] init];	
	_pauseObjects = [[NSMutableArray alloc] init];
	
	NSMutableArray *dbSprites = [Database getSprites:[NSString stringWithFormat: @"%d", _level] InDatabase:[Utils appDelegate].database];
	for(int i = ([dbSprites count]-1); i >= 0; i--)
	{
		Sprite *item = [dbSprites objectAtIndex:i];
		
		int _typeId = 0;
		if([item.type isEqualToString:@"MAILBOX"]) { _typeId = TARGET_MAILBOX; }
		else if([item.type isEqualToString:@"BUILDING"]) { _typeId = TARGET_BUILDING; }
		else if([item.type isEqualToString:@"BIGBUILDING"]) { _typeId = TARGET_BIGBUILDING; }
		else if([item.type isEqualToString:@"GIRDER"]) { _typeId = TARGET_GIRDER; }
		else if([item.type isEqualToString:@"MOVINGGIRDER"]) { _typeId = TARGET_MOVINGGIRDER; }
		else if([item.type isEqualToString:@"DOWNER"]) { _typeId = TARGET_DOWNER; }
		else if([item.type isEqualToString:@"BOMBFUSE"]) { _typeId = TARGET_FUSEBOX; }
		
		[self addTarget:_typeId x:item.x y:item.y imagefile:item.imagefile];
	}
	
	if(_wind < 0) {
		[self addParticleEffect:PARTICLE_EFFECT_WINDLEFT x:320 y:200];	
	}
	
	[self addPlane:_speed];
	NSString *value = [[Globals sharedInstance] music];
	if([value isEqualToString:@"YES"]) {
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"prop_planeidle.mp3"];
	}
	
	
	CCMenuItem *pauseMenuItem = [CCMenuItemImage 
										   itemFromNormalImage:@"pausebutton.png" selectedImage:@"pausebutton.png" 
										   target:self selector:@selector(pauseGame)];
	CCMenu* pauseMenu = [CCMenu menuWithItems:pauseMenuItem, nil];
	pauseMenu.position = ccp(20,304);
	[self addChild:pauseMenu];
	
	//now the labels for scoring and such
	fontTimer = [CCLabelBMFont labelWithString:[@"Time: " stringByAppendingString:[NSString stringWithFormat:@"%002d", _time]] fntFile:@"coopheavy.fnt"];
	fontTimer.position = ccp(40, 290);
	fontTimer.anchorPoint=ccp(0.0f,0.0f);
	[self addChild:fontTimer];
	
	fontPackages = [CCLabelBMFont labelWithString:[@"x " stringByAppendingString:[NSString stringWithFormat:@"%01d", _packages_remaining]] fntFile:@"coopheavy.fnt"];
	fontPackages.position = ccp(445, 290);
	fontPackages.anchorPoint=ccp(0.0f,0.0f);
	[self addChild:fontPackages];
	CCSprite *pkgSprite = [[CCSprite alloc] initWithFile:@"packageicon.png"];
	pkgSprite.position = ccp(427, 304);
	[self addChild:pkgSprite];
	
	fontBombs = [CCLabelBMFont labelWithString:[@"x " stringByAppendingString:[NSString stringWithFormat:@"%01d", _bombs_remaining]] fntFile:@"coopheavy.fnt"];
	fontBombs.position = ccp(445, 265);
	fontBombs.anchorPoint=ccp(0.0f,0.0f);
	[self addChild:fontBombs];
	CCSprite *bombSprite = [[CCSprite alloc] initWithFile:@"bombsmall.png"];
	bombSprite.position = ccp(428, 280);
	[self addChild:bombSprite];
	
	// Standard method to create a button
	CCMenuItem *swapProjectileMenuItem = [CCMenuItemImage 
								itemFromNormalImage:@"switch_top.png" selectedImage:@"switch_top.png" 
								target:self selector:@selector(swapProjectiles)];
	swapProjectileMenuItem.position = ccp(392, 290);
	
	swapMenuTop = [CCMenu menuWithItems:swapProjectileMenuItem, nil];
	swapMenuTop.position = CGPointZero;
	[self addChild:swapMenuTop];
	
	CCMenuItem *swapProjectileMenuItem2 = [CCMenuItemImage 
										  itemFromNormalImage:@"switch_bottom.png" selectedImage:@"switch_bottom.png" 
										  target:self selector:@selector(swapProjectiles)];
	swapProjectileMenuItem2.position = ccp(392, 290);
	
	swapMenuBottom = [CCMenu menuWithItems:swapProjectileMenuItem2, nil];
	swapMenuBottom.position = ccp(-2000,-2000);
	[self addChild:swapMenuBottom];
	
	
	//now start the game timer and update scheduler
	[self schedule:@selector(gameLogic:) interval:0.1];	
	[self schedule:@selector(gameTimer:) interval:1.0];
}

- (void)swapProjectiles {
    if(_currently_loaded_projectile == PROJECTILE_PACKAGE)
	{
		_currently_loaded_projectile = PROJECTILE_BOMB;
		swapMenuBottom.position = CGPointZero;
		swapMenuTop.position =  ccp(-2000,-2000);
	}
	else {
		_currently_loaded_projectile = PROJECTILE_PACKAGE;
		swapMenuBottom.position = ccp(-2000,-2000);
		swapMenuTop.position = CGPointZero;
	}

}

- (void)gameTimer:(ccTime)dt {
	_time--;
	
	if(_time >= 0) 
	{
		[fontTimer setString:[@"Time: " stringByAppendingString:[NSString stringWithFormat:@"%002d", _time]]];
		[self checkLevelCompleted];
	}
	else
	{
		//game is over because time ran out!!		
		NSString *backgroundPath = @"game_failed_bg.png";
		CCSprite *mboxSprite;
		mboxSprite = [[CCSprite alloc] initWithFile:backgroundPath];
		[mboxSprite _setZOrder:100];
		mboxSprite.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:mboxSprite];
		
		
		// Standard method to create a button
		CCMenuItem *replayMenuItem = [CCMenuItemImage 
									  itemFromNormalImage:@"tryagain.png" selectedImage:@"tryagain_over.png" 
									  target:self selector:@selector(replayLevel)];
		replayMenuItem.position = ccp(winSize.width/2, winSize.height/2 + 5);
		
		// Standard method to create a button
		CCMenuItem *levelSelectMenuItem = [CCMenuItemImage 
										   itemFromNormalImage:@"levelselect.png" selectedImage:@"levelselect_over.png" 
										   target:self selector:@selector(levelMenu)];
		levelSelectMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 55);
		
		
		// Standard method to create a button
		CCMenuItem *quitMenuItem = [CCMenuItemImage 
									itemFromNormalImage:@"quitgame.png" selectedImage:@"quitgame_over.png" 
									target:self selector:@selector(quitGame)];
		quitMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 115);
		
		CCMenu *starMenu = [CCMenu menuWithItems:replayMenuItem, levelSelectMenuItem, quitMenuItem, nil];
		starMenu.position = CGPointZero;
		[starMenu _setZOrder:101];
		[self addChild:starMenu];
		
		[self unschedule:@selector(gameTimer:)];	
	}
}

- (void)dialogPressed {
	return;
}

- (void)checkLevelCompleted {
	
	if(_goal <= _packages_score && _packages_remaining == 0 && [_projectiles count] == 0)
	{
		//you win level!
		//now calculate the score
		int totalscore = (_time * _packages_score) + (_bombs_remaining * _time) * 100;
		_points = _points + totalscore;
		
		
		//unlock the next level!
		[Database updateLevelLocked:[NSString stringWithFormat:@"%d", _level + 1] InDatabase:[Utils appDelegate].database]; 
       
		
		[[SimpleAudioEngine sharedEngine]  stopBackgroundMusic];
		[self playSoundEffect:SOUND_EFFECT_LEVEL_COMPLETE];
		
		NSString *backgroundPath = @"game_win_bg.png";
		CCSprite *mboxSprite;
		mboxSprite = [[CCSprite alloc]  initWithFile:backgroundPath];
		[mboxSprite _setZOrder:100];
		mboxSprite.position = ccp(winSize.width/2, winSize.height/2);
		[self addChild:mboxSprite];
		
		// Standard method to create a button
		CCMenuItem *nextLevelMenuItem = [CCMenuItemImage 
											itemFromNormalImage:@"nextlevel.png" selectedImage:@"nextLevel_over.png" 
											target:self selector:@selector(nextLevel)];
		nextLevelMenuItem.position = ccp(winSize.width/2, winSize.height/2 + 5);
		
		// Standard method to create a button
		CCMenuItem *levelSelectMenuItem = [CCMenuItemImage 
										  itemFromNormalImage:@"levelselect.png" selectedImage:@"levelselect_over.png" 
										  target:self selector:@selector(levelMenu)];
		levelSelectMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 55);
		
		
		// Standard method to create a button
		CCMenuItem *quitMenuItem = [CCMenuItemImage 
										 itemFromNormalImage:@"quitgame.png" selectedImage:@"quitgame_over.png" 
										 target:self selector:@selector(quitGame)];
		quitMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 115);
		
		CCMenu *starMenu = [CCMenu menuWithItems:nextLevelMenuItem, levelSelectMenuItem, quitMenuItem, nil];
		starMenu.position = CGPointZero;
		[starMenu _setZOrder:101];
		[self addChild:starMenu];
		
		//this needs to be replaced with a) update next level to be unlocked, b) show game over screen, c) game over screen either 
		//goes back to the level menu or moves to next level
		//LevelSelectScene *levelScene = [LevelSelectScene node];
		//[[CCDirector sharedDirector] replaceScene:levelScene];
		
		[self unschedule:@selector(gameTimer:)];		
		
		NSLog([NSString stringWithFormat:@"Total SCore! %d", _points]);
		if(_currentHighScore < _points) {
			[Database updateLevelHighScore:[NSString stringWithFormat:@"%d", _level] points:[NSString stringWithFormat:@"%d", _points] InDatabase:[Utils appDelegate].database];	
			NSString *msg = [@"high score of " stringByAppendingString:[NSString stringWithFormat:@"%d", _points]];
			//[Utils alertMessage: [msg stringByAppendingString:@" points for this level!"]];
			CCLayer *dialogLayer = [[[DialogLayer alloc]
									 initWithHeader:@""
									 andLine1:@"Congratulations, you scored a new"
									 andLine2:[msg stringByAppendingString:@" points!"]
									 andLine3:@""
									 target:self
									 selector:@selector(dialogPressed)] autorelease];
			[self addChild:dialogLayer z:200];
		}
	}
	else if (_packages_remaining == 0 && _packages_score < _goal && [_projectiles count] == 0)
	{
	  //you have no packages left but haven't reached the goal target, you lose level :(	  
	
	  NSString *backgroundPath = @"game_failed_bg.png";
	  CCSprite *mboxSprite;
	  mboxSprite = [[CCSprite alloc] initWithFile:backgroundPath];
	  [mboxSprite _setZOrder:100];
	  mboxSprite.position = ccp(winSize.width/2, winSize.height/2);
	  [self addChild:mboxSprite];
		
		
		// Standard method to create a button
		CCMenuItem *replayMenuItem = [CCMenuItemImage 
										 itemFromNormalImage:@"tryagain.png" selectedImage:@"tryagain_over.png" 
										 target:self selector:@selector(replayLevel)];
		replayMenuItem.position = ccp(winSize.width/2, winSize.height/2 + 5);
		
		// Standard method to create a button
		CCMenuItem *levelSelectMenuItem = [CCMenuItemImage 
										   itemFromNormalImage:@"levelselect.png" selectedImage:@"levelselect_over.png" 
										   target:self selector:@selector(levelMenu)];
		levelSelectMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 55);
		
		
		// Standard method to create a button
		CCMenuItem *quitMenuItem = [CCMenuItemImage 
									itemFromNormalImage:@"quitgame.png" selectedImage:@"quitgame_over.png" 
									target:self selector:@selector(quitGame)];
		quitMenuItem.position = ccp(winSize.width/2, winSize.height/2 - 115);
		
		CCMenu *starMenu = [CCMenu menuWithItems:replayMenuItem, levelSelectMenuItem, quitMenuItem, nil];
		starMenu.position = CGPointZero;
		[starMenu _setZOrder:101];
		[self addChild:starMenu];
		
		[self unschedule:@selector(gameTimer:)];		
	}
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://lemonadestand.com.au/apps/index.php?redir=airmail-lite"]];
        
    }
}

-(void)planeExplodeWindupTimer:(ccTime)dt {
	_packages_remaining = 0;
	_bombs_remaining = 0;
	[self removeChildByTag:PARTICLE_EFFECT_PLANEEXPLOSION cleanup:YES];
	//[planeSprite stopAllActions];
}

- (void)gameLogic:(ccTime)dt {
	NSMutableArray *projectilesToDelete = [[NSMutableArray alloc] init];
	NSMutableArray *targetsToDelete = [[NSMutableArray alloc] init];
		
	if(_paused == 0 && _time >= 0)
	{	 
		
		CGRect planeRect = CGRectMake(planeSprite.position.x - (planeSprite.contentSize.width/2), 
									  planeSprite.position.y - (planeSprite.contentSize.height/2), 
									  planeSprite.contentSize.width, 
									  planeSprite.contentSize.height);
		
		for (CCSprite *target in _targets) 
		{
			CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2), 
										   target.position.y - (target.contentSize.height/2), 
										   target.contentSize.width, 
										   target.contentSize.height);
		
			if(CGRectIntersectsRect(planeRect, targetRect) && (target.tag == TARGET_BUILDING || target.tag == TARGET_BIGBUILDING))
			{
				//plane explodes!
				[self playSoundEffect:SOUND_EFFECT_BOMB_EXPLODE];
				[self addParticleEffect:PARTICLE_EFFECT_PLANEEXPLOSION x:planeSprite.position.x y:planeSprite.position.y];
				planeSprite.opacity =0;
				[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
				[self schedule:@selector(planeExplodeWindupTimer:) interval:0.85];
			}
		}
		
		
		//find any targets (presents) that intersect with projectiles (bombs, packages)
		for (CCSprite *projectile in _projectiles) {
			CGRect projectileRect = CGRectMake(projectile.position.x - (projectile.contentSize.width/2), 
											   projectile.position.y - (projectile.contentSize.height/2), 
											   projectile.contentSize.width, 
											   projectile.contentSize.height);
			
			
			for (CCSprite *target in _targets) {
				CGRect targetRect = CGRectMake(target.position.x - (target.contentSize.width/2), 
											   target.position.y - (target.contentSize.height/2), 
											   target.contentSize.width, 
											   target.contentSize.height);
				
				if (CGRectIntersectsRect(projectileRect, targetRect) && target.tag == TARGET_MAILBOX) {
					[projectilesToDelete addObject:projectile];	
					if(projectile.tag == PROJECTILE_PACKAGE) { 						
						[self playSoundEffect:SOUND_EFFECT_PACKAGE_SCORE];
						[self addParticleEffect:PARTICLE_EFFECT_MAIL_DELIVERED x:target.position.x y:target.position.y];
						_packages_score++;
						[self addToScore:target.position.x posy:target.position.y value:500];
						
						//replace the target with a postbox full target
						[targetsToDelete addObject:target];	
						int fullX = target.position.x;
						int fullY = (target.position.y + 5);
						target.tag = 0;
						target.position = ccp(-2000,-2000);
						[self addTarget:TARGET_MAILBOX_FULL x:fullX y:fullY imagefile:@"postbox_full.png"];
					}
					else if(projectile.tag == PROJECTILE_BOMB) { 						
						[self playSoundEffect:SOUND_EFFECT_BOMB_EXPLODE];
						[self addParticleEffect:PARTICLE_EFFECT_EXPLOSION x:projectile.position.x y:projectile.position.y];	
					}
				}	
				else if (CGRectIntersectsRect(projectileRect, targetRect) && (target.tag == TARGET_BUILDING || target.tag == TARGET_BIGBUILDING) && projectile.position.y >= 6){
					[projectilesToDelete addObject:projectile];	
					if(projectile.tag == PROJECTILE_PACKAGE) { 
						[self playSoundEffect:SOUND_EFFECT_BOMB_EXPLODE];
						[self addParticleEffect:PARTICLE_EFFECT_EXPLOSION x:projectile.position.x y:projectile.position.y];	
					}
					else if(projectile.tag == PROJECTILE_BOMB) { 
						[self playSoundEffect:SOUND_EFFECT_BUILDING_COLLAPSE];
						[self addParticleEffect:PARTICLE_EFFECT_EXPLOSION x:projectile.position.x y:projectile.position.y];
						[self addParticleEffect:PARTICLE_EFFECT_BUILDING_COLLAPSE x:target.position.x y:7];
						
						[self addToScore:target.position.x posy:target.position.y value:100];
						
						//add the building crumble effect for this building						
						int negativeImpact = (target.contentSizeInPixels.height / 3);
						if (target.contentSizeInPixels.height <= 100) { negativeImpact = 50; } //if it's a short buildilng it can go down in 2 bombs
						
						id buildingActionMove = [CCMoveTo actionWithDuration:2.0 position:ccp(target.position.x, target.position.y - negativeImpact)];
						id buildingActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(buildingCompleted:)];
						[target runAction:[CCSequence actions:buildingActionMove, buildingActionCompleted, nil]];						
					}
				}
				else if(CGRectIntersectsRect(projectileRect, targetRect) && (target.tag == TARGET_GIRDER || target.tag == TARGET_MOVINGGIRDER) && projectile.position.y >= 6){
					[projectilesToDelete addObject:projectile];	
					[self playSoundEffect:SOUND_EFFECT_BOMB_EXPLODE];	
					[self addParticleEffect:PARTICLE_EFFECT_EXPLOSION x:projectile.position.x y:projectile.position.y];					
					[targetsToDelete addObject:target];	
				}
				else if(CGRectIntersectsRect(projectileRect, targetRect) && target.tag == TARGET_DOWNER && projectile.position.y >= 6){
					//plane goes down 50px
					[targetsToDelete addObject:target];						
					_planeY = _planeY - 40;
				}
				else if(CGRectIntersectsRect(projectileRect, targetRect) && target.tag == TARGET_FUSEBOX && projectile.position.y >= 6){
					[projectilesToDelete addObject:projectile];						
					[self addParticleEffect:PARTICLE_EFFECT_MAIL_DELIVERED x:projectile.position.x y:projectile.position.y];
					[self addToScore:target.position.x posy:target.position.y value:300];										
					[targetsToDelete addObject:target];	
					
					for (CCSprite *bigBuilding in _targets) {
						if(bigBuilding.tag == TARGET_BIGBUILDING) {
							int negativeImpact = (bigBuilding.contentSizeInPixels.height / 2.5);
							[self addParticleEffect:PARTICLE_EFFECT_EXPLOSION x:bigBuilding.position.x y:bigBuilding.position.y];
							[self addParticleEffect:PARTICLE_EFFECT_BUILDING_COLLAPSE x:bigBuilding.position.x y:7];
							id buildingActionMove = [CCMoveTo actionWithDuration:2.0 position:ccp(bigBuilding.position.x, bigBuilding.position.y - negativeImpact)];
							id buildingActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(buildingCompleted:)];
							[bigBuilding runAction:[CCSequence actions:buildingActionMove, buildingActionCompleted, nil]];	
						}
					}
				}
			}
			
		}
	}
	
	//remove the projectile
	for (CCSprite *projectile in projectilesToDelete) {
		[_projectiles removeObject:projectile];
		[self removeChild:projectile cleanup:YES];
	}		
	[projectilesToDelete release];
	
	//remove the projectile
	for (CCSprite *targetDel in targetsToDelete) {	
		targetDel.position = ccp(-2000, -2000);
		[self removeChild:targetDel cleanup:YES];
		[_targets removeObject:targetDel];
	}						 
	[targetsToDelete release];
}

//submits a score to apple's gamecenter
-(void)submitGameCenterScore:(int)score {
	GKScore *myScoreValue = [[[GKScore alloc] initWithCategory:@"AirMailLeaderboard1"] autorelease];
    myScoreValue.value = score;
	
    [myScoreValue reportScoreWithCompletionHandler:^(NSError *error){
        if(error != nil){
            NSLog(@"Score Submission Failed");
        } else {
            NSLog(@"Score Submitted");
        }
		
    }];
}


//don't need to do anything here
- (void)buildingActionMove:(id)sender {
}

//stop particle effect
- (void)buildingCompleted:(id)sender {	
	[self removeChildByTag:PARTICLE_EFFECT_BUILDING_COLLAPSE cleanup:YES];
	//CCSprite *buildingSprite = (CCSprite*)sender;
}



- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];      
    return TRUE;    
}


- (void)selectSpriteForTouch:(CGPoint)touchLocation {
	CCSprite *planeSprite = (CCSprite*)[self getChildByTag:99];
	
	//this will add a bomb sprite to the scene then remove 1 bomb from the count
	if(_currently_loaded_projectile == PROJECTILE_BOMB && _bombs_remaining > 0)
	{
		CCSprite *projectileSprite = [[CCSprite alloc] initWithFile:@"bombsmall.png"];
		projectileSprite.position = ccp(planeSprite.position.x + 10, planeSprite.position.y - 20);
		projectileSprite.tag = PROJECTILE_BOMB;
		[self addChild:projectileSprite];
		
		id projectileActionMove = [CCMoveTo actionWithDuration:2.0 position:ccp(planeSprite.position.x + 120 + _wind, -35)];
		id projectileActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(projectileCompleted:)];
		[projectileSprite runAction:[CCSequence actions:projectileActionMove, projectileActionCompleted, nil]];
		
		[_projectiles addObject:projectileSprite];
		_bombs_remaining--;
		[self playSoundEffect:SOUND_EFFECT_BOMB_WHISTLE];
		[fontBombs setString:[@"x " stringByAppendingString:[NSString stringWithFormat:@"%01d", _bombs_remaining]]];
	}
	else if(_currently_loaded_projectile == PROJECTILE_PACKAGE && _packages_remaining > 0)
	{
		CCSprite *projectileSprite = [[CCSprite alloc] initWithFile:@"package1.png"];
		projectileSprite.position = ccp(planeSprite.position.x + 10, planeSprite.position.y - 20);
		projectileSprite.tag = PROJECTILE_PACKAGE;
		[self addChild:projectileSprite];
		
		id projectileActionMove = [CCMoveTo actionWithDuration:2.0 position:ccp(planeSprite.position.x + 120 + _wind, -35)];
		id projectileActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(projectileCompleted:)];
		[projectileSprite runAction:[CCSequence actions:projectileActionMove, projectileActionCompleted, nil]];
		
		[_projectiles addObject:projectileSprite];
		_packages_remaining--;
		[self playSoundEffect:SOUND_EFFECT_PACKAGE_DROP];
		[fontPackages setString:[@"x " stringByAppendingString:[NSString stringWithFormat:@"%01d", _packages_remaining]]];
	}
}

- (void)projectileCompleted:(id)sender {
	[_projectiles removeObject:sender];
	[self removeChild:sender cleanup:YES];
}

- (void)addToScore:(int)posx posy:(int)posy value:(int)value {
	CCLabelTTF *lblScore = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",value] fontName:@"Arial" fontSize:10];
	lblScore.position = ccp(posx , posy);
	id projectileActionMove = [CCMoveTo actionWithDuration:1.2 position:ccp(lblScore.position.x + 40, lblScore.position.y + 40)];
	id projectileActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(labelScoreCompleted:)];
	[lblScore runAction:[CCSequence actions:projectileActionMove, projectileActionCompleted, nil]];
	[self addChild:lblScore];
	_points = _points + value;
}

- (void)labelScoreCompleted:(id)sender {
	[self removeChild:sender cleanup:YES];
}

- (void)addTarget:(int)type x:(int)x y:(int)y imagefile:(NSString*)imagefile {
	CCSprite *mboxSprite;
	//add a target 
	mboxSprite = [[CCSprite alloc] initWithFile:imagefile];
	mboxSprite.position = ccp(x,y);
	[self addChild:mboxSprite z:1 tag:type];
	
	if(type == TARGET_DOWNER) {
		//add an extra movement animation to this 
		id targetActionWiggle = [CCMoveTo actionWithDuration:0.45 position:ccp(mboxSprite.position.x, mboxSprite.position.y - 5)];
		id targetActionWiggle2 = [CCMoveTo actionWithDuration:0.45 position:ccp(mboxSprite.position.x, mboxSprite.position.y + 5)];
		CCSequence * rotSeq = [CCSequence actions:targetActionWiggle, targetActionWiggle2, nil];
		[mboxSprite runAction:[CCRepeatForever actionWithAction:rotSeq]];      	
	}
	else if(type == TARGET_MOVINGGIRDER) {
		//add an extra movement animation to this 
		id targetActionMove = [CCMoveTo actionWithDuration:1.0 position:ccp(mboxSprite.position.x, mboxSprite.position.y + 35)];
		id targetActionMove2 = [CCMoveTo actionWithDuration:1.0 position:ccp(mboxSprite.position.x, mboxSprite.position.y - 35)];
		CCSequence * movSeq = [CCSequence actions:targetActionMove, targetActionMove2, nil];
		[mboxSprite runAction:[CCRepeatForever actionWithAction:movSeq]];      	
	}
	
	[_targets addObject:mboxSprite];
}


- (void)addPlane:(float)planeSpeed {
	planeSprite = [[CCSprite alloc] initWithFile:@"biplane.png"];
	planeSprite.position = ccp(-48, _planeY);
	[self addChild:planeSprite z:1 tag:99];
	
	id planeActionMove = [CCMoveTo actionWithDuration:planeSpeed position:ccp(48, (_planeY - 20))];
	id planeActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(planeCompleted:)];
	[planeSprite runAction:[CCSequence actions:planeActionMove, planeActionCompleted, nil]];
	
	//add spotlight sprite
	/*
	spotlightSprite = [[CCSprite alloc] initWithFile:@"spotlight.png"];
	spotlightSprite.position = ccp(48 + 25, (_planeY - 20*6));
	id spotlightActionMove = [CCMoveTo actionWithDuration:planeSpeed position:ccp((48*2)+25, (_planeY - 20*7))];
	id spotlightActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(spotlightCompleted:)];
	[spotlightSprite runAction:[CCSequence actions:spotlightActionMove, spotlightActionCompleted, nil]];
	[spotlightSprite _setZOrder:3];
	[self addChild:spotlightSprite];*/
}

- (void)planeCompleted:(id)sender {	
	int _targetY = (_planeY - 20);
	int _targetX = planeSprite.position.x + 96;
	if(_targetX >= 532) {
		_targetX = 48;
		planeSprite.position = ccp(-48, planeSprite.position.y);
	}
	if(planeSprite.position.y < _planeY) {
		_targetY = _planeY;
	}
	
	id planeActionMove = [CCMoveTo actionWithDuration:_speed position:ccp(_targetX, _targetY)];
	id planeActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(planeCompleted:)];
	[planeSprite runAction:[CCSequence actions:planeActionMove, planeActionCompleted, nil]];
}

- (void)spotlightCompleted:(id)sender {	
	int _targetY = (_planeY - 20*7);
	int _targetX = planeSprite.position.x + 96;
	if(_targetX >= 532) {
		_targetX = 48 + 25;
		spotlightSprite.position = ccp(-48, planeSprite.position.y - 20*6);
	}
	if(spotlightSprite.position.y < _planeY) {
		_targetY =  (_planeY - 20*6);
	}
	
	id spotlightActionMove = [CCMoveTo actionWithDuration:_speed position:ccp(_targetX, _targetY)];
	id spotlightActionCompleted = [CCCallFuncN actionWithTarget:self selector:@selector(spotlightCompleted:)];
	[spotlightSprite runAction:[CCSequence actions:spotlightActionMove, spotlightActionCompleted, nil]];	
}

- (void)addParticleEffect:(int)type x:(int)x y:(int)y {
	//below are two line examples of adding and removing an effect
	//[self addParticleEffect:PARTICLE_EFFECT_BUILDING_COLLAPSE x:100 y:100];
	//[self removeChildByTag:PARTICLE_EFFECT_BUILDING_COLLAPSE cleanup:YES];
	
	CCParticleSystem *system;
	
	switch(type) {
		case 6:
			//add a mail delivered effect
			[self removeChildByTag:PARTICLE_EFFECT_MAIL_DELIVERED cleanup:YES];
			system = [CCParticleSystemQuad particleWithFile:@"Particle_MailDelivered.plist"];
			break;
		case 7:
			//add a building collapsing effect
			[self removeChildByTag:PARTICLE_EFFECT_BUILDING_COLLAPSE cleanup:YES];
			system = [CCParticleSystemQuad particleWithFile:@"Particle_BuildingCrumble.plist"];
			break;
		case 8:
			//add a explode effect
			[self removeChildByTag:PARTICLE_EFFECT_EXPLOSION cleanup:YES];
			system = [CCParticleSystemQuad particleWithFile:@"Particle_Explode.plist"];
			break;
		case 9:
			//add a wind-left effect
			[self removeChildByTag:PARTICLE_EFFECT_WINDLEFT cleanup:YES];
			system = [CCParticleSystemQuad particleWithFile:@"Particle_WindLeft.plist"];
			break;
		case 11:
			//add a explode effect
			[self removeChildByTag:PARTICLE_EFFECT_PLANEEXPLOSION cleanup:YES];
			system = [CCParticleSystemQuad particleWithFile:@"Particle_PlaneExplode.plist"];
			break;
		default:
			break;
	}	
	
	system.position = CGPointMake(x, y);
	[self addChild:system z:10 tag:type];
}


- (void)playSoundEffect:(int)type {
	NSString *value = [[Globals sharedInstance] effects];
	if([value isEqualToString:@"YES"]) {	
		switch (type) {
		case 1:
			[[SimpleAudioEngine sharedEngine] playEffect:@"success_sound_exploding_glass_01.mp3"];
			break;
		case 2:
			[[SimpleAudioEngine sharedEngine] playEffect:@"battle003-explosion.mp3"];
			break;
		case 3:
			[[SimpleAudioEngine sharedEngine] playEffect:@"battle047-impactgroundtargets.mp3"];
			break;
		case 4:
			[[SimpleAudioEngine sharedEngine] playEffect:@"orchestral_ta_da_stinger_01.mp3"];
			break;
		case 5:
			[[SimpleAudioEngine sharedEngine] playEffect:@"parachute_open_05.mp3"];
			break;
		case 6:
			[[SimpleAudioEngine sharedEngine] playEffect:@"bomb_whistle06.mp3"];
		default:
			break;
		}
	}
}

- (void)unpauseGame {
	NSLog(@"un Paused!");
	
	for(CCSprite *sprite in _pauseObjects) {		
		[self removeChild:sprite cleanup:YES];	
	}
	for(CCMenu *menu in _pauseObjects) {		
		[self removeChild:menu cleanup:YES];	
	}
	[_pauseObjects removeAllObjects];
	
	_paused = 0;	
	[self resumeSchedulerAndActions];
	for (CCSprite *sprite in _projectiles) {
		[sprite resumeSchedulerAndActions];
	}
	 
	 [planeSprite resumeSchedulerAndActions];
}

- (void)pauseGame {
	NSLog(@"Paused!");
	CCSprite *backgroundMenuSprite = [[CCSprite alloc] initWithFile:@"paused.png"];
	backgroundMenuSprite.position = ccp(winSize.width/2, winSize.height/2);
	[backgroundMenuSprite _setZOrder:998];
	[self addChild:backgroundMenuSprite];
	[_pauseObjects addObject:backgroundMenuSprite];
	
	// Standard method to create a button
	CCMenuItem *menuItem = [CCMenuItemImage 
							itemFromNormalImage:@"quitgame.png" selectedImage:@"quitgame_over.png" 
							target:self selector:@selector(quitGame)];
	menuItem.position = ccp(winSize.width/2, winSize.height/2 - 65);
	
	
	// Standard method to create a button
	CCMenuItem *gameStartMenuItem = [CCMenuItemImage 
									 itemFromNormalImage:@"resumebutton.png" selectedImage:@"resumebutton_over.png" 
									 target:self selector:@selector(unpauseGame)];
	gameStartMenuItem.position = ccp(winSize.width/2, winSize.height/2);
	
	CCMenu *pauseMenu = [CCMenu menuWithItems: gameStartMenuItem, menuItem, nil];
	pauseMenu.position = CGPointZero;
	[pauseMenu _setZOrder:999];
	[self addChild:pauseMenu];
	[_pauseObjects addObject:pauseMenu];
	
	_paused = 1;	
	
	[planeSprite pauseSchedulerAndActions];
	[self pauseSchedulerAndActions];
	for (CCSprite *sprite in _projectiles) {
		[sprite pauseSchedulerAndActions];
	}
	
}

- (void)levelMenu {
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[CCDirector sharedDirector] replaceScene:[[[LevelSelectScene alloc] init] autorelease]];
}

- (void)replayLevel {
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		GamePlayScene *gameScene = [GamePlayScene node];
		gameScene.layer._level = _level;
		[gameScene.layer loadLevelData];
		[[CCDirector sharedDirector] replaceScene:gameScene];
}

- (void)nextLevel {
  if(_level + 1 < 21)
  {
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	GamePlayScene *gameScene = [GamePlayScene node];
	gameScene.layer._level = _level + 1;
	[gameScene.layer loadLevelData];
	[[CCDirector sharedDirector] replaceScene:gameScene];
  }
  else 
  {
	  //that's all the levels we have
	  [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	  [[CCDirector sharedDirector] replaceScene:[[[GameMenuScene alloc] init] autorelease]];
  }    
}

- (void)quitGame {
	[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
	[[CCDirector sharedDirector] replaceScene:[[[GameMenuScene alloc] init] autorelease]];
}


// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	[_targets release];
	_targets = nil;
	
	[_projectiles release];
	_projectiles = nil;
	
	[[CCSpriteFrameCache sharedSpriteFrameCache] removeUnusedSpriteFrames];
	
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
