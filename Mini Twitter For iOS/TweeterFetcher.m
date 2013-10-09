
//
//  TweeterFetcher.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "TweeterFetcher.h"
#import "AFJSONRequestOperation.h"

@interface TweeterFetcher()
@property (nonatomic) ACAccountStore *accountStore;
@end

@implementation TweeterFetcher
NSString  * const TWITTER_DEFALT_USER_ACCESS_INFORMATION = @"user_access_information";

NSString  * const TWITTER_ACCESS_TOKEN_KEY = @"oauth_token";
NSString  * const TWITTER_ACCESS_TOKEN_SECRET = @"oauth_token_secret";
NSString  * const TWITTER_ACCESS_TOKEN_USER_ID = @"user_id";
NSString  * const TWITTER_ACCESS_TOKEN_SCREEN_NAME = @"screen_name";

NSString  * const TWITTER_TWEET_MESSAGE = @"text";
NSString  * const TWITTER_TWEET_TIMESTAMP = @"created_at";
NSString  * const TWITTER_TWEET_USER = @"user";
NSString  * const TWITTER_TWEET_ID = @"id";
NSString  * const TWITTER_TWEET_ID_STR = @"id_str";

NSString  * const TWITTER_FOLLOW_USERS = @"users";
NSString  * const TWITTER_FOLLOW_CURSOR_PREVIOUS = @"previous_cursor";
NSString  * const TWITTER_FOLLOW_CURSOR_PREVIOUS_STR = @"previous_cursor_str";
NSString  * const TWITTER_FOLLOW_CURSOR_NEXT = @"next_cursor";

NSString  * const TWITTER_USER_NAME = @"name";
NSString  * const TWITTER_USER_USERNAME = @"screen_name";
NSString  * const TWITTER_USER_ID = @"id";
NSString  * const TWITTER_USER_FOLLOWING = @"following";
NSString  * const TWITTER_USER_ID_STR = @"id_str";
NSString  * const TWITTER_USER_PROFILE_IMAGE_URL = @"profile_image_url";
NSString  * const TWITTER_USER_FOLLOWERS_COUNT = @"followers_count";
NSString  * const TWITTER_USER_FOLLOWING_COUNT = @"friends_count";
NSString  * const TWITTER_USER_TWEETS_COUNT = @"statuses_count";

NSString * const baseApiUrl = @"https://api.twitter.com/1.1/";
NSString * const consumerKey = @"BhnnJQsTflOlwJpGkh9SA";
NSString * const consumerSecret = @"Fl6eBHtJyBkOZnVRcAG5atqOBRFMdkNZ6bu86CfjgCc";

- (id)init {
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:consumerKey andSecret:consumerSecret];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    return self;
}
- (NSString*)loadAccessToken {
    NSString* accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:TWITTER_DEFALT_USER_ACCESS_INFORMATION];
    return accessToken;
}

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:TWITTER_DEFALT_USER_ACCESS_INFORMATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loginUserViewController:(UIViewController *)sender
                CompletionBlock:(LoginCompletionBlock)loginCompletionBlock
                 dispatcherQueue:(dispatch_queue_t)dispatcherQueue {
    if ([self loadAccessToken].length > 0) {
        dispatch_async(dispatcherQueue, ^{
            loginCompletionBlock(YES);
        });
        return;
    }
    [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:sender
                                                                withCompletion:^(BOOL success) {
        dispatch_async(dispatcherQueue, ^{
            loginCompletionBlock(success);
        });
    }];
}

- (void)logoutUserViewController:(UIViewController *)sender
                CompletionBlock:(LogoutCompletionBlock)logoutCompletionBlock
                dispatcherQueue:(dispatch_queue_t)dispatcherQueue {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TWITTER_DEFALT_USER_ACCESS_INFORMATION];
    dispatch_async(dispatcherQueue, ^{
        logoutCompletionBlock(YES);
    });
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)signRequest:(NSMutableURLRequest *) request {
    NSString* tokenKey = [Utils extractValueForKey:TWITTER_ACCESS_TOKEN_KEY fromHTTPBody:[self loadAccessToken]];
    NSString* tokenSecret = [Utils extractValueForKey:TWITTER_ACCESS_TOKEN_SECRET fromHTTPBody:[self loadAccessToken]];
    
    [[FHSTwitterEngine sharedEngine] signRequest:request withToken:tokenKey tokenSecret:tokenSecret verifier:nil];
}

- (void)sendRequest:(NSURLRequest *) request
    completionBlock:(APICompletionBlock)apiCompletionBlock
    dispatcherQueue:(dispatch_queue_t)dispatcherQueue {
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //NSLog(@"Api Response Data for : %@",JSON);
        dispatch_async(dispatcherQueue, ^{
            apiCompletionBlock(JSON);
        });
    } failure:^(NSURLRequest *request,
                NSHTTPURLResponse *response,
                NSError *error,
                id JSON) {
        NSLog(@"ERROR OCCURRED: %@", [error localizedDescription]);
    }];
    [operation start];
}

- (void)fetchPostFromApi:(NSString *)api
              withParams:(NSDictionary *)params
         completionBlock:(APICompletionBlock)apiCompletionBlock
         dispatcherQueue:(dispatch_queue_t)dispatcherQueue {
    NSURL *url = [NSURL URLWithString:[baseApiUrl stringByAppendingString:api]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setHTTPShouldHandleCookies:NO];
    NSString *boundary = [NSString fhs_UUID];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
    [self signRequest:request];
    
    NSMutableData *body = [NSMutableData dataWithLength:0];
    for (NSString *key in params.allKeys) {
        id obj = params[key];
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        NSData *data = nil;
        if ([obj isKindOfClass:[NSData class]]) {
            [body appendData:[@"Content-Type: application/octet-stream\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            data = (NSData *)obj;
        } else if ([obj isKindOfClass:[NSString class]]) {
            data = [[NSString stringWithFormat:@"%@\r\n",(NSString *)obj]dataUsingEncoding:NSUTF8StringEncoding];
        }
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
    }
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setValue:@(body.length).stringValue forHTTPHeaderField:@"Content-Length"];
    request.HTTPBody = body;
    
    [self sendRequest:request
      completionBlock:apiCompletionBlock
      dispatcherQueue:dispatcherQueue];
}

- (NSString *)mt_url_remove_params:(NSURL *)url {
    if (url.absoluteString.length == 0) {
        return nil;
    }
    
    NSArray *parts = [url.absoluteString componentsSeparatedByString:@"?"];
    return (parts.count == 0)?nil:parts[0];
}

- (void)fetchGetFromApi:(NSString *)api
             withParams:(NSDictionary *)params
          completionBlock:(APICompletionBlock)apiCompletionBlock
          dispatcherQueue:(dispatch_queue_t)dispatcherQueue {
    NSURL *url = [NSURL URLWithString:[baseApiUrl stringByAppendingString:api]];
    if (params.count > 0) {
        NSMutableArray *paramPairs = [NSMutableArray arrayWithCapacity:params.count];
        for (NSString *key in params) {
            NSString *paramPair = [NSString stringWithFormat:@"%@=%@",[key fhs_URLEncode],[params[key] fhs_URLEncode]];
            [paramPairs addObject:paramPair];
        }
        NSString *urlWithOutParams = [self mt_url_remove_params:url];
        url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?%@",urlWithOutParams, [paramPairs componentsJoinedByString:@"&"]]];
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setHTTPShouldHandleCookies:NO];
    [self signRequest:request];
    [self sendRequest:request
      completionBlock:apiCompletionBlock
      dispatcherQueue:dispatcherQueue];
}

- (void)fetchTimelineForUser:(NSString *)username
             completionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                       maxId:(NSString*)maxId {
    NSString *api = @"statuses/user_timeline.json";
    
    NSMutableDictionary *params = [@{ @"screen_name" : username,
                                   @"include_rts" : @"0",
                                   @"count" : @"50" } mutableCopy];
    
    if (![maxId isEqualToString: @"-1"]) {
        params[@"max_id"] = maxId;
    }
    [self fetchGetFromApi:api
            withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}

- (void)fetchTimelineForUser:(NSString *)username
             completionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                       sinceId:(NSString *)sinceId {
    NSString *api = @"statuses/user_timeline.json";
    NSMutableDictionary *params = [@{ @"screen_name" : username,
                                   @"include_rts" : @"0",
                                   @"count" : @"50" } mutableCopy];
    if (![sinceId isEqualToString: @"-1"]) {
        params[@"since_id"] = sinceId;
    }
    [self fetchGetFromApi:api
            withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}

- (void)fetchHomeTimelineForCurrentUserCompletionBlock:(APICompletionBlock)apiCompletionBlock
                                       dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                                                 maxId:(NSString*) maxId {
    NSString *api = @"statuses/home_timeline.json";
    NSMutableDictionary *params =  [@{ @"include_rts" : @"0",
                                    @"count" : @"20" } mutableCopy];

    if (![maxId isEqualToString: @"-1"]) {
        params[@"max_id"] = maxId;
    }
    
    [self fetchGetFromApi:api
               withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}

- (void)fetchHomeTimelineForCurrentUserCompletionBlock:(APICompletionBlock)apiCompletionBlock
                                       dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                                               sinceId:(NSString *)sinceId {
    NSString *api = @"statuses/home_timeline.json";
    NSMutableDictionary *params =  [@{ @"include_rts" : @"0",
                                    @"count" : @"20" } mutableCopy];
    
    if (![sinceId isEqualToString: @"-1"]) {
        params[@"since_id"] = sinceId;
    }
    
    [self fetchGetFromApi:api
               withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}

- (void)postTweet:(NSString*)tweet
  completionBlock:(APICompletionBlock)apiCompletionBlock
  dispatcherQueue:(dispatch_queue_t)dispatcherQueue {
    NSString *api = @"statuses/update.json";
    NSDictionary *params = @{ @"status" : tweet };
    [self fetchPostFromApi:api
                withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}

- (void)fetchDetailsForUser:(NSString *)username
            completionBlock:(APICompletionBlock)apiCompletionBlock
            dispatcherQueue:(dispatch_queue_t)dispatcherQueue {
    NSString *api = @"users/show.json";
    NSDictionary *params = @{ @"screen_name" : username };
    [self fetchGetFromApi:api
            withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}

- (void)fetchFollowersForUser:(NSString *)username
              completionBlock:(APICompletionBlock)apiCompletionBlock
              dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                   nextCursor:(NSString*)nextCursor {
    NSString *api = @"followers/list.json";
    NSDictionary *params = @{ @"screen_name" : username,
                             @"cursor": nextCursor };
    [self fetchGetFromApi:api
            withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}

- (void)fetchFollowingForUser:(NSString *)username
              completionBlock:(APICompletionBlock)apiCompletionBlock
              dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                   nextCursor:(NSString*)nextCursor {
    NSString *api = @"friends/list.json";
    NSDictionary *params = @{ @"screen_name" : username,
                             @"cursor": nextCursor };
    [self fetchGetFromApi:api
               withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}
@end
