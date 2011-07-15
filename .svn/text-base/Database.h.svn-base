//
//  db.h
//  testdb
//
//  Created by Created by Lemonadestand.com.au on 11/2/08.
//  Copyright 2008 zxZX. All rights reserved.
//

//handle database setup, etc

#import <sqlite3.h>
#import "Fav.h"
#import "Setting.h"
#import "Level.h"
#import "Sprite.h"

@interface Database : NSObject {
	sqlite3* database;	
}
- (sqlite3 *)openDatabase;
+ (void)closeDatabase:(sqlite3 *)database;
+ (void)finalizeStatements;
- (void)setDatabasePath;
- (void)createEditableCopyOfDatabaseIfNeeded;

+ (NSMutableArray*)getSettings:(sqlite3 *)db;
+ (NSMutableArray*)getFavourites:(sqlite3 *)db;
+ (void)insertFavourite:(Fav*)item InDatabase:(sqlite3 *)db;
+ (void)updateEffects:(NSString*)value InDatabase:(sqlite3 *)db;
+ (void)updateMusic:(NSString*)value InDatabase:(sqlite3 *)db;
+ (void)updatePlayername:(NSString*)value InDatabase:(sqlite3 *)db;
+ (NSMutableArray*)getLevels:(sqlite3 *)db;
+ (NSMutableArray*)getAllLevels:(sqlite3 *)db;
+ (NSMutableArray*)getLevelsGreaterThanId:(NSString*)levelid InDatabase:(sqlite3 *)db;
+ (void)updateLevelLocked:(NSString*)levelid InDatabase:(sqlite3 *)db;
+ (Level*)getLevel:(NSString*)levelid InDatabase:(sqlite3 *)db;
+ (NSMutableArray*)getSprites:(NSString*)levelid InDatabase:(sqlite3 *)db;
+ (void)updateLevelHighScore:(NSString*)levelid points:(NSString*)points InDatabase:(sqlite3*)db;
@end
