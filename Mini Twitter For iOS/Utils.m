//
//  Utils.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 05/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "Utils.h"
#import "NSDate+TimeAgo.h"

@implementation Utils
+(NSString*) convertTweetNSDateToTimeAgo:(NSDate*)tweetTime {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  //      [dateFormatter setDateFormat: @"EEE MMM dd HH:mm:ss Z yyyy"];
//        NSDate *date = [dateFormatter dateFromString:tweetTime];
        return [tweetTime timeAgo];
    
}

+(NSDate*) convertTweetDateStringToTweetNSDate:(id)tweetDateString {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"EEE MMM dd HH:mm:ss Z yyyy"];
    NSDate *tweetNSDate = [dateFormatter dateFromString:tweetDateString];
    return tweetNSDate;
}

-(NSString *) convertTweetDateToStringTimeStamp:(NSDate*) date{
    NSDateFormatter *dateToStringFormatter = [[NSDateFormatter alloc] init];
    [dateToStringFormatter setDateFormat: @"dd-MM-yyyy HH:mm"];

    NSString* convertedString = [dateToStringFormatter stringFromDate:date];
    NSLog(@"String date: %@",convertedString);
    return convertedString;

}

- (NSString *)extractValueForKey:(NSString *)target fromHTTPBody:(NSString *)body {
    if (body.length == 0) {
        return nil;
    }
    
    if (target.length == 0) {
        return nil;
    }
	
	NSArray *tuples = [body componentsSeparatedByString:@"&"];
	if (tuples.count < 1) {
        return nil;
    }
	
	for (NSString *tuple in tuples) {
		NSArray *keyValueArray = [tuple componentsSeparatedByString:@"="];
		
		if (keyValueArray.count >= 2) {
			NSString *key = [keyValueArray objectAtIndex:0];
			NSString *value = [keyValueArray objectAtIndex:1];
			
			if ([key isEqualToString:target]) {
                return value;
            }
		}
	}
	
	return nil;
}
@end
