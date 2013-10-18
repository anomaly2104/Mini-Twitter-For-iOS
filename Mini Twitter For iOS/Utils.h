//
//  Utils.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 05/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject
+ (NSString *)appendString:(NSString *)stringA withString:(NSString *)stringB;
+(NSString *) convertTweetNSDateToTimeAgo:(NSDate*) tweetTime;
+(NSDate*) convertTweetDateStringToTweetNSDate:(id)tweetDateString;
+(NSString *)extractValueForKey:(NSString *)target fromHTTPBody:(NSString *)body;

-(NSString *) convertTweetDateToStringTimeStamp:(NSDate*) date;


@end
