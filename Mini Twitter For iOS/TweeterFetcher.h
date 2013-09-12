//
//  TweeterFetcher.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accounts/ACAccountStore.h>
#import <Accounts/ACAccountType.h>
#import <Social/Social.h>

#import "ResponseCreator.h"
#import "User.h"

#define TWITTER_TWEET_MESSAGE @"text"
#define TWITTER_TWEET_TIMESTAMP @"created_at"
#define TWITTER_TWEET_USER @"user"
#define TWITTER_TWEET_ID @"id"

#define TWITTER_USER_NAME @"name"
#define TWITTER_USER_USERNAME @"screen_name"
#define TWITTER_USER_ID @"id"
#define TWITTER_USER_PROFILE_IMAGE_URL @"profile_image_url"
#define TWITTER_USER_FOLLOWERS_COUNT @"followers_count"
#define TWITTER_USER_FOLLOWING_COUNT @"friends_count"

typedef void (^ APICompletionBlock)(NSDictionary *);
typedef void (^ FetchCurrentUserCompletionBlock)(ACAccount *);

@interface TweeterFetcher : NSObject
- (void)fetchTimelineForUser:(NSString *)username
             completionBlock:(APICompletionBlock) apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t) dispatcherQueue;
- (void)fetchHomeTimelineForCurrentUserCompletionBlock:(APICompletionBlock)apiCompletionBlock
    dispatcherQueue:(dispatch_queue_t)dispatcherQueue;

- (void) getCurrentLoggedInUserCompletionBlock:(FetchCurrentUserCompletionBlock)completionBlock
                              dispatcherQueue:(dispatch_queue_t)dispatcherQueue;
- (void)postTweet:(NSString*)tweet
  completionBlock:(APICompletionBlock)apiCompletionBlock
  dispatcherQueue:(dispatch_queue_t)dispatcherQueue;

@end
