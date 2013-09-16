//
//  Tweet+Twitter.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "Tweet+Twitter.h"
#import "User+Twitter.h"
#import "Utils.h"
#import "TweeterFetcher.h"

@implementation Tweet (Twitter)
+(Tweet*) tweetWithTwitterData:(NSDictionary*) tweetTwitterData{
    Tweet *tweet = nil;
    
    tweet= [[Tweet alloc] init];
    tweet.tweetTimestamp = [Utils convertTweetDateStringToTweetNSDate: [tweetTwitterData objectForKey:TWITTER_TWEET_TIMESTAMP]];
    tweet.tweetMessage = [tweetTwitterData objectForKey:TWITTER_TWEET_MESSAGE];
    tweet.tweetId = [tweetTwitterData objectForKey:TWITTER_TWEET_ID];
    
    tweet.tweetedBy = [User userWithTwitterData:[tweetTwitterData objectForKey:TWITTER_TWEET_USER]];
    
    return tweet;
}
@end
