//
//  Utils.m
//  Taksee
//
//  Created by Created by Lemonadestand.com.au on 2/11/09.
//  Copyright 2009 zxZX. All rights reserved.
//

#import "Utils.h"


@implementation Utils

+(Cocos2DSimpleGameAppDelegate*)appDelegate{
	return (Cocos2DSimpleGameAppDelegate*)[[UIApplication sharedApplication]delegate];
}

+(NSString*)stringFromFileNamed:(NSString*)name{
	NSString* result = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
	return result;
}

+(NSString*)getAppVersion{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

+(UIColor*)colorFromDict:(NSDictionary*)dict{
	UIColor* color = [UIColor colorWithRed:[[dict objectForKey:@"Red"] floatValue]/255.0
									 green:[[dict objectForKey:@"Green"] floatValue]/255.0
									  blue:[[dict objectForKey:@"Blue"] floatValue]/255.0
									 alpha:1];
	return color;
}

+(NSString*)appDocDir{
	//get app doc dir
	NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES); 
	NSString* docDir = [paths objectAtIndex:0];
	return docDir;
}

+ (NSString *) getMD5Sum:(NSString *)str
{
	const char *cStr = [str UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, strlen(cStr), result );
	str = [NSString stringWithFormat:
		   @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
		   result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
		   result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
		   ];
	return str;	
}

+(void)showSubViewWithNameNoAnimation:(NSString*)name withDelegate:(id)delegate {
	Class klass = NSClassFromString(name);
	id vc = [[[klass alloc] initWithNibName:name bundle:nil] autorelease];
	[[delegate navigationController] pushViewController:vc animated:NO];
}


+(void)showSubViewWithName:(NSString*)name withDelegate:(id)delegate{
	Class klass = NSClassFromString(name);
	id vc = [[[klass alloc] initWithNibName:name bundle:nil] autorelease];
	[[delegate navigationController] pushViewController:vc animated:YES];
}


+(float)calculateHeightOfMultipleLineText:(NSString*)text withFont:(UIFont*)font withWidth:(float)width{
	CGSize boundingSize = CGSizeMake(width, CGFLOAT_MAX);
	CGSize requiredSize = [text sizeWithFont:font
						   constrainedToSize:boundingSize
							   lineBreakMode:UILineBreakModeWordWrap];
	float height = requiredSize.height + 20;
	if (height < 44)
		height = 44;
	return height;
}


+(void)alertMessage:(NSString*)msg{
	if([msg isEqualToString:@"no internet connection"]){
		msg = @"No Internet Connection";
	}
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:msg
												   delegate:nil cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
}

+(void)alertMessage:(NSString*)msg withSecondButtonTitle:(NSString*)title delegate:(id)delegate{
	UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"" message:msg
												   delegate:delegate cancelButtonTitle:@"Cancel"
										  otherButtonTitles:title,nil];
	[alert show];
	[alert release];
}


+(NSDateComponents*)getCurrentDateComponent{
	//get current time	
	NSCalendar* calendar = [NSCalendar currentCalendar];	
	
	unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit| NSHourCalendarUnit
	|NSMinuteCalendarUnit|NSSecondCalendarUnit;
	NSDate *date = [NSDate date];
	NSDateComponents *comps2 = [calendar components:unitFlags fromDate:date];
	return comps2;
}

+(NSString*)getCurrentDate{
	NSDateComponents* comps2 = [Utils getCurrentDateComponent];
	
	NSString* timestamp = [NSString stringWithFormat:@"%02d-%02d",[comps2 month],[comps2 day]
						   ];
	return timestamp;
}


+(NSString*)toSlashDate:(NSString*)date{
	NSArray* parts = [date componentsSeparatedByString:@"-"];
	if([parts count] < 3)
		return date;
	return [NSString stringWithFormat:@"%@/%@/%@", [parts objectAtIndex:1], 
			[parts objectAtIndex:2], [parts objectAtIndex:0]];
}

+(NSString*)dateStringFromTimestamp:(NSString*)timestamp{	
	NSDateFormatter *dateFormatter =[[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSDate *date =[NSDate dateWithTimeIntervalSince1970:[timestamp intValue]];
	NSString *formattedDateString = [dateFormatter stringFromDate:date];
	NSLog(@"formattedDateString for locale %@: %@",
		  [[dateFormatter locale] localeIdentifier], formattedDateString);
	// Output: formattedDateString for locale en_US: Jan 2, 2001
	return formattedDateString;
}


+(void) handleError:(NSError*)error{
	
}

+(NSString*)removeHtmlTags:(NSString*)html{
	
	NSString* regex = @"<.+?>";
    NSString* text = [html stringByReplacingOccurrencesOfRegex:regex withString:@""];
	return text;
	
}

+(NSString*)UTCStringToLocalString:(NSString*)time{
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss Z"];
	
	NSDate *formatterDate = [inputFormatter dateFromString:time ]; //@"Thu, 13 Aug 2009 06:18:21 +0000"];
	
	NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
	[outputFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss"];
	
	NSString *newDateString = [outputFormatter stringFromDate:formatterDate];
	
	NSLog(@"newDateString %@", newDateString);
	return newDateString;
	// For US English, the output is:
	// newDateString 10:30 on Sunday July 11	
}



@end
