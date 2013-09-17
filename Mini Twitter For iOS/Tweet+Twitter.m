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
+(Tweet*) tweetWithTwitterData:(NSDictionary *)tweetTwitterData inManagedObjectContext:(NSManagedObjectContext *)context {
    Tweet *tweet = nil;

    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"tweetId = %@", [tweetTwitterData valueForKey:TWITTER_TWEET_ID_STR]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tweetTimestamp" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet" inManagedObjectContext:context];
        tweet.tweetTimestamp = [Utils convertTweetDateStringToTweetNSDate: [tweetTwitterData objectForKey:TWITTER_TWEET_TIMESTAMP]];
        tweet.tweetMessage = [tweetTwitterData objectForKey:TWITTER_TWEET_MESSAGE];
        tweet.tweetId = [tweetTwitterData objectForKey:TWITTER_TWEET_ID_STR];
        
        tweet.tweetedBy = [User userWithTwitterData:[tweetTwitterData objectForKey:TWITTER_TWEET_USER] inManagedObjectContext:context];
    } else {
        tweet = [matches lastObject];
    }
    
    return tweet;
}
@end
