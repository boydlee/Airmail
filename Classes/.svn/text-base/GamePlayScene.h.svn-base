
#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Globals.h"

// GamePlay Layer
@interface GamePlay : CCColorLayer
{
	CGSize winSize;
	NSMutableArray *_targets;
	NSMutableArray *_projectiles;
	NSMutableArray *_pauseObjects;
	int _points;
	int _goal;
	int _bombs_remaining;
	int _packages_remaining;
	int _packages_score;
	int _level;
	int _time;
	float _speed;
	int _wind;
	int _currently_loaded_projectile;
	int _currentHighScore;
	int _paused;
	CCLabelBMFont *fontPackages;
	CCLabelBMFont *fontBombs;
	CCLabelBMFont *fontScore;
	CCLabelBMFont *fontTimer;
	CCMenu *swapMenuBottom;
	CCMenu *swapMenuTop;
	CCSprite *planeSprite;
	CCSprite *spotlightSprite;
	int _planeY;
}

@property int _level;
- (void)submitGameCenterScore:(int)score;
- (void)loadLevelData;
- (void)addTarget:(int)type x:(int)x y:(int)y imagefile:(NSString*)imagefile;
- (void)addPlane:(float)planeSpeed;
- (void)addToScore:(int)posx posy:(int)posy value:(int)value;
- (void)unpauseGame;
- (void)pauseGame;
- (void)quitGame;
- (void)levelMenu;
- (void)nextLevel;
- (void)replayLevel;
- (void)checkLevelCompleted;
- (void)playSoundEffect:(int)type;
- (void)addParticleEffect:(int)type x:(int)x y:(int)y;
- (void)selectSpriteForTouch:(CGPoint)touchLocation;

@end

@interface GamePlayScene : CCScene
{
    GamePlay *_layer;
}
@property (nonatomic, retain) GamePlay *layer;
@end

