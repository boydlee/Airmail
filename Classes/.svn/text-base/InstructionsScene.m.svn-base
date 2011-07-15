//
//  GameOverScene.m
//  Cocos2DSimpleGame
//
//  Created by Ray Wenderlich on 2/10/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "InstructionsScene.h"
#import "SimpleAudioEngine.h"
#import "GameMenuScene.h"
#import "Database.h"
#import "Utils.h"

@implementation InstructionsScene
@synthesize layer = _layer;

- (id)init {
	
	if ((self = [super init])) {
		self.layer = [InstructionsLayer node];
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

@implementation InstructionsLayer


-(id) init
{
	if( (self=[super initWithColor:ccc4(255,255,255,255)] )) {
		
		CGSize winSize = [[CCDirector sharedDirector] winSize];
		
		CCSprite *backgroundMenuSprite = [[CCSprite alloc] initWithFile:@"settings_bg.png"];
		backgroundMenuSprite.position = ccp(winSize.width/2, winSize.height/2);
		//[backgroundMenuSprite _setZOrder:1];
		[self addChild:backgroundMenuSprite];
		
		
		// Standard method to create a button
		CCMenuItem *homeButton = [CCMenuItemImage 
								  itemFromNormalImage:@"backbutton.png" selectedImage:@"backbutton_on.png" 
								  target:self selector:@selector(settingsDone)];
		
		CCMenu *starMenu = [CCMenu menuWithItems:homeButton, nil];
		starMenu.position = ccp(28,295);
		//[starMenu _setZOrder:3];
		[self addChild:starMenu];
		
		int _top = 175;
		int _left = 165;
		
		CCLabelTTF *_label = [CCLabelTTF labelWithString:@"Sound Effects" dimensions:CGSizeMake(250, 30) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:25];
		_label.position = ccp(_left,_top);
		[_label setColor:ccBLACK];
		[self addChild:_label];
		
		CCLabelTTF *_label2 = [CCLabelTTF labelWithString:@"Background Music" dimensions:CGSizeMake(250, 30) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:25];
		_label2.position = ccp(_left,_top + 45);
		[_label2 setColor:ccBLACK];
		[self addChild:_label2];
		
		CCLabelTTF *_label3 = [CCLabelTTF labelWithString:@"Player Name" dimensions:CGSizeMake(250, 30) alignment:UITextAlignmentLeft fontName:@"Helvetica" fontSize:25];
		_label3.position = ccp(_left,_top + -45);
		[_label3 setColor:ccBLACK];
		[self addChild:_label3];
		
		moreButton = [CCMenuItemImage 
					   itemFromNormalImage:@"button_moregames.png" selectedImage:@"button_moregames_over.png" 
					   target:self selector:@selector(moreGamesOpenSafari:)];		
		moreButton.position = ccp(winSize.width/2 - 264, winSize.height/2 - 160);
		
		
		howtoButton = [CCMenuItemImage 
						 itemFromNormalImage:@"button_howtoplay.png" selectedImage:@"button_howtoplay_over.png" 
						 target:self selector:@selector(howtoLoad:)];		
		howtoButton.position = ccp(winSize.width/2 - 38, winSize.height/2 - 160);
		
		
		effectsButton = [CCMenuItemImage 
								  itemFromNormalImage:@"on.png" selectedImage:@"on.png" 
						 target:self selector:@selector(effectsOff:)];		
		effectsButton.position = ccp(winSize.width/2, winSize.height/2 -45);
		
		effectsButtonOff = [CCMenuItemImage 
						 itemFromNormalImage:@"off.png" selectedImage:@"off.png" 
						 target:self selector:@selector(effectsOn:)];		
		effectsButtonOff.position = ccp(2000,2000);
		
		NSString *effectString = [[Globals sharedInstance] effects];
		if([effectString isEqualToString:@"NO"]) {
			effectsButtonOff.position = ccp(winSize.width/2, winSize.height/2 -45);
			effectsButton.position = ccp(2000,2000);
		}
		
		musicButton = [CCMenuItemImage 
									 itemFromNormalImage:@"on.png" selectedImage:@"on.png" 
					   target:self selector:@selector(musicOff:)];
		musicButton.position = ccp(winSize.width/2, winSize.height/2);
		
		musicButtonOff = [CCMenuItemImage 
							itemFromNormalImage:@"off.png" selectedImage:@"off.png" 
							target:self selector:@selector(musicOn:)];		
		musicButtonOff.position =  ccp(2000,2000);
		
		NSString *musicString = [[Globals sharedInstance] music];
		if([musicString isEqualToString:@"NO"]) {			
			musicButtonOff.position = ccp(winSize.width/2, winSize.height/2);
			musicButton.position = ccp(2000,2000);
		}

		
		CCMenu *optionsMenu = [CCMenu menuWithItems:moreButton, howtoButton, effectsButton, musicButton, effectsButtonOff, musicButtonOff, nil];
		optionsMenu.position = ccp(150, 58);
		//[optionsMenu _setZOrder:5];
		[self addChild:optionsMenu];
		
		answerBox = [[UITextField alloc] initWithFrame:CGRectMake(270,177,170,30)];
		[answerBox setTextColor:[UIColor blackColor]];
		[answerBox setTextAlignment:UITextAlignmentLeft];
		[answerBox setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
		[answerBox setClearsOnBeginEditing:YES];
		[answerBox setBorderStyle:UITextBorderStyleRoundedRect];
		answerBox.text = [[Globals sharedInstance] playerName];		
		answerBox.hidden = NO;
		
		[answerBox setDelegate:self];
		[answerBox setReturnKeyType:UIReturnKeyDone];
		[answerBox setAutocapitalizationType:UITextAutocapitalizationTypeWords];
		[[[CCDirector sharedDirector] openGLView] addSubview: answerBox];
		[[[CCDirector sharedDirector] openGLView] bringSubviewToFront:answerBox];
	}	
	return self;
}

- (void)playSoundEffect {
	[[SimpleAudioEngine sharedEngine] playEffect:@"clickon.mp3"];
}

-(void) moreGamesOpenSafari:(id)sender {
	[self playSoundEffect];
	NSURL *url = [[NSURL alloc] initWithString: @"http://www.lemonadestand.com.au/games.html"];
	[[UIApplication sharedApplication] openURL:url];
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
	//Terminate editing
	[textField resignFirstResponder];
	return YES;
}
- (void)textFieldDidEndEditing:(UITextField*)textField {
    if (textField==answerBox) {
        [answerBox endEditing:YES];
        // here is where you should do something with the data they entered
        [[Globals sharedInstance] setPlayerName:answerBox.text];
		[Database updatePlayername:answerBox.text InDatabase:[Utils appDelegate].database];
    }
}

-(void) hideHowTo:(id)sender {		
	[self removeChild:instructionsButtonImage cleanup:YES];
	[self removeChild:howtoMenu cleanup:YES];
	answerBox.hidden = NO;
}

-(void) howtoLoad:(id)sender {	
	answerBox.hidden = YES;
	CGSize winSize = [[CCDirector sharedDirector] winSize];
	instructionsButtonImage = [CCMenuItemImage 
				   itemFromNormalImage:@"instructions.png" selectedImage:@"instructions.png" 
				   target:self selector:@selector(hideHowTo:)];
	instructionsButtonImage.position = ccp(winSize.width/2, winSize.height/2);
	instructionsButtonImage.tag = 1;
	
	howtoMenu = [CCMenu menuWithItems:instructionsButtonImage,  nil];
	howtoMenu.position = CGPointZero;
	[howtoMenu _setZOrder:6];
	[self addChild:howtoMenu];
	
	[howtoButton unselected];
}

- (void) musicOn:(id)sender {
	CGSize winSize = [[CCDirector sharedDirector] winSize];		
	[[Globals sharedInstance] setMusic:@"YES"];
	[Database updateMusic:@"YES" InDatabase:[Utils appDelegate].database];
	[musicButtonOff setPosition: ccp(2000,2000)];
	[musicButton setPosition: ccp(winSize.width/2, winSize.height/2)];
}

- (void) effectsOn:(id)sender {	
	CGSize winSize = [[CCDirector sharedDirector] winSize];		
	[[Globals sharedInstance] setEffects:@"YES"];
	[Database updateEffects:@"YES" InDatabase:[Utils appDelegate].database];
	[effectsButtonOff setPosition: ccp(2000,2000)];
	[effectsButton setPosition: ccp(winSize.width/2, winSize.height/2 -45)];
}
- (void) musicOff:(id)sender {
	CGSize winSize = [[CCDirector sharedDirector] winSize];		
	[[Globals sharedInstance] setMusic:@"NO"];
	[Database updateMusic:@"NO" InDatabase:[Utils appDelegate].database];
	[musicButton setPosition: ccp(2000,2000)];
	[musicButtonOff setPosition: ccp(winSize.width/2, winSize.height/2)];
    [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

- (void) effectsOff:(id)sender {	
	CGSize winSize = [[CCDirector sharedDirector] winSize];	
	[[Globals sharedInstance] setEffects:@"NO"];
	[Database updateEffects:@"NO" InDatabase:[Utils appDelegate].database];	
	[effectsButton setPosition: ccp(2000,2000)];
	[effectsButtonOff setPosition: ccp(winSize.width/2, winSize.height/2 -45)];
}

- (void) settingsDone {	
	[self playSoundEffect];	
	answerBox.hidden = YES;
	[answerBox removeFromSuperview];
	[[CCDirector sharedDirector] replaceScene:[[[GameMenuScene alloc] init] autorelease]];	
}

- (void)dealloc {
	[super dealloc];
}

@end
