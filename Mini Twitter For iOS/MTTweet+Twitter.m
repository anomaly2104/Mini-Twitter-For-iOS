//
//  Tweet+Twitter.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTTweet+Twitter.h"
#import "MTUser+Twitter.h"
#import "Utils.h"
#import "TweeterFetcher.h"

@implementation MTTweet (TwitterAdditions)

+ (MTTweet *)tweetWithTwitterData:(NSDictionary *)tweetTwitterData
           inManagedObjectContext:(NSManagedObjectContext *)context {
    MTTweet *tweet = nil;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"MTTweet"];
    request.predicate = [NSPredicate predicateWithFormat:@"tweetId = %@",
                         [tweetTwitterData valueForKey:TWITTER_TWEET_ID_STR]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"tweetTimestamp" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        tweet = [NSEntityDescription insertNewObjectForEntityForName:@"MTTweet" inManagedObjectContext:context];
        tweet.tweetTimestamp = [Utils convertTweetDateStringToTweetNSDate: [tweetTwitterData objectForKey:TWITTER_TWEET_TIMESTAMP]];
        tweet.tweetMessage = [tweetTwitterData objectForKey:TWITTER_TWEET_MESSAGE];
        tweet.tweetId = [tweetTwitterData objectForKey:TWITTER_TWEET_ID_STR];
        tweet.tweetedBy = [MTUser userWithTwitterData:[tweetTwitterData objectForKey:TWITTER_TWEET_USER]
                               inManagedObjectContext:context];
    } else {
        tweet = [matches lastObject];
    }
    return tweet;
}
@end
