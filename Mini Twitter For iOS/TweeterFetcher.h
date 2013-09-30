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

#import "FHSTwitterEngine.h"
#import "MTUser.h"
#import "Utils.h"

extern NSString  * const TWITTER_DEFALT_USER_ACCESS_INFORMATION;

extern NSString  * const TWITTER_ACCESS_TOKEN_KEY;// @"oauth_token";
extern NSString  * const TWITTER_ACCESS_TOKEN_SECRET;// @"oauth_token_secret"
extern NSString  * const TWITTER_ACCESS_TOKEN_USER_ID;// @"user_id"
extern NSString  * const TWITTER_ACCESS_TOKEN_SCREEN_NAME;// @"screen_name"

extern NSString  * const TWITTER_TWEET_MESSAGE;// @"text";
extern NSString  * const TWITTER_TWEET_TIMESTAMP;// @"created_at";
extern NSString  * const TWITTER_TWEET_USER;// @"user";
extern NSString  * const TWITTER_TWEET_ID;// @"id";
extern NSString  * const TWITTER_TWEET_ID_STR;// @"id_str";

extern NSString  * const TWITTER_FOLLOW_USERS;// @"users"
extern NSString  * const TWITTER_FOLLOW_CURSOR_PREVIOUS;// @"previous_cursor"
extern NSString  * const TWITTER_FOLLOW_CURSOR_PREVIOUS_STR;// @"previous_cursor_str"
extern NSString  * const TWITTER_FOLLOW_CURSOR_NEXT;// @"next_cursor"

extern NSString  * const TWITTER_USER_NAME;// @"name";
extern NSString  * const TWITTER_USER_USERNAME;// @"screen_name";
extern NSString  * const TWITTER_USER_ID;// @"id";
extern NSString  * const TWITTER_USER_FOLLOWING;// @"following";
extern NSString  * const TWITTER_USER_ID_STR;// @"id_str";
extern NSString  * const TWITTER_USER_PROFILE_IMAGE_URL;// @"profile_image_url";
extern NSString  * const TWITTER_USER_FOLLOWERS_COUNT;// @"followers_count";
extern NSString  * const TWITTER_USER_FOLLOWING_COUNT;// @"friends_count";
extern NSString  * const TWITTER_USER_TWEETS_COUNT;// @"statuses_count";

typedef void (^APICompletionBlock)(NSDictionary *);
typedef void (^LoginCompletionBlock)(BOOL);
typedef void (^LogoutCompletionBlock)(BOOL);
typedef void (^FetchCurrentUserCompletionBlock)(ACAccount *);

@interface TweeterFetcher : NSObject <FHSTwitterEngineAccessTokenDelegate>

@property (nonatomic, strong) NSString *tokenData;

- (void)loginUserViewController:(UIViewController *)sender
                CompletionBlock:(LoginCompletionBlock)loginCompletionBlock
                dispatcherQueue:(dispatch_queue_t)dispatcherQueue;

- (void)logoutUserViewController:(UIViewController *)sender
                 CompletionBlock:(LogoutCompletionBlock)logoutCompletionBlock
                 dispatcherQueue:(dispatch_queue_t)dispatcherQueue;

- (void)fetchTimelineForUser:(NSString *)username
             completionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                       maxId:(NSString *)maxId;

- (void)fetchTimelineForUser:(NSString *)username
             completionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                     sinceId:(NSString *)sinceId;

- (void)fetchHomeTimelineForCurrentUserCompletionBlock:(APICompletionBlock)apiCompletionBlock
                                       dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                                                 maxId:(NSString *)maxId;

- (void)fetchHomeTimelineForCurrentUserCompletionBlock:(APICompletionBlock)apiCompletionBlock
                                       dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                                                 sinceId:(NSString *)sinceId;

- (void)postTweet:(NSString *)tweet
  completionBlock:(APICompletionBlock)apiCompletionBlock
  dispatcherQueue:(dispatch_queue_t)dispatcherQueue;

- (void)fetchDetailsForUser:(NSString *)username
            completionBlock:(APICompletionBlock) apiCompletionBlock
            dispatcherQueue:(dispatch_queue_t) dispatcherQueue;

- (void)fetchFollowingForUser:(NSString *)username
              completionBlock:(APICompletionBlock)apiCompletionBlock
              dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                   nextCursor:(NSString *)nextCursor;

- (void)fetchFollowersForUser:(NSString *)username
              completionBlock:(APICompletionBlock)apiCompletionBlock
              dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                   nextCursor:(NSString *)nextCursor;
@end
