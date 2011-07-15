//
//  InstructionsScene.h
//  The AntiSanta
//
//  Created by Boydlee Pollentine on 2/12/10.
//  Copyright 2010 Boydlee Pollentine. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "cocos2d.h"
#import "Globals.h"

@interface InstructionsLayer : CCColorLayer<UITextInputDelegate,UITextFieldDelegate> {
	CCMenuItem *effectsButton;
	CCMenuItem *musicButton;
	CCMenuItem *effectsButtonOff;
	CCMenuItem *musicButtonOff;
	CCMenuItem *howtoButton;
	CCMenuItem *moreButton;
	CCMenuItem *instructionsButtonImage;
	CCMenu *howtoMenu;
	UITextField *answerBox;
}


@end

@interface InstructionsScene : CCScene {
	InstructionsLayer *_layer;
}

@property (nonatomic, retain) InstructionsLayer *layer;

@end
