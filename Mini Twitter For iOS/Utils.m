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
+(NSString*) convertTweetTimeToTimeAgo:(id)tweetTime {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat: @"EEE MMM dd HH:mm:ss Z yyyy"];        
        NSDate *date = [dateFormatter dateFromString:tweetTime];
        return [date timeAgo];
}
@end
