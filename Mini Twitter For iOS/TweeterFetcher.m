//
//  TweeterFetcher.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "TweeterFetcher.h"
@interface TweeterFetcher()
@property (nonatomic) ACAccountStore *accountStore;
@end

@implementation TweeterFetcher
NSString* baseApiUrl = @"https://api.twitter.com/1.1/";
NSString* consumerKey = @"BhnnJQsTflOlwJpGkh9SA";
NSString* consumerSecret = @"Fl6eBHtJyBkOZnVRcAG5atqOBRFMdkNZ6bu86CfjgCc";

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:consumerKey andSecret:consumerSecret];
    
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    
    return self;
}
- (NSString*) loadAccessToken{
    NSString* accessToken= [[NSUserDefaults standardUserDefaults] objectForKey:TWITTER_DEFALT_ACCESS_TOKEN];
    return accessToken;
}
-(void) storeAccessToken:(NSString *)accessToken{
    [[NSUserDefaults standardUserDefaults] setObject:accessToken forKey:TWITTER_DEFALT_ACCESS_TOKEN];
    NSLog(@"Access Token: %@" , accessToken);
}

-(void) loginUserViewController:(UIViewController* ) sender
                CompletionBlock:(LoginCompletionBlock) loginCompletionBlock
                 dispatcherQueue:(dispatch_queue_t)dispatcherQueue
{
    
    [[FHSTwitterEngine sharedEngine]showOAuthLoginControllerFromViewController:sender withCompletion:^(BOOL success) {
        dispatch_async(dispatcherQueue, ^{
            loginCompletionBlock(success);
        });
    }];
}

- (BOOL)userHasAccessToTwitter
{
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}



/*
api =   @"/statuses/user_timeline.json"    
params =    @{@"screen_name" : username,
              @"include_rts" : @"0",
              @"trim_user" : @"1",
              @"count" : @"10"};
 */

-(void) someTests:(SLRequest*)slRequest{
    }

- (void) fetchCurrentUserCompletionBlock:(FetchCurrentUserCompletionBlock)completionBlock
                         dispatcherQueue:(dispatch_queue_t)dispatcherQueue
 {
     NSLog(@"Fetching current user");
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [self.accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 ACAccount* twitterAccount = [twitterAccounts lastObject];

                 dispatch_async(dispatcherQueue, ^{
                     completionBlock(twitterAccount);
                 });
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"Some error occurred: %@", [error localizedDescription]);
             }
         }];
    } else {
        NSLog(@"User does not have access.");
    }
}

- (void) fetchPostFromApi:(NSString *)api withParams:(NSDictionary *) params
      completionBlock:(APICompletionBlock)apiCompletionBlock
      dispatcherQueue:(dispatch_queue_t)dispatcherQueue

{
}
- (void) fetchGetFromApi:(NSString *)api withParams:(NSDictionary *) params
          completionBlock:(APICompletionBlock)apiCompletionBlock
          dispatcherQueue:(dispatch_queue_t)dispatcherQueue

{
    NSURL* apiURL = [NSURL URLWithString:[baseApiUrl stringByAppendingString:api]];
    NSString* oauthHeader = [[FHSTwitterEngine sharedEngine] buildOAuthHeaderForRequestForMethod:@"" forUrl:apiURL];
    NSLog(@"AUTH HEADER : %@" , oauthHeader);
}
- (void) fetchFromApi:(NSString *)api withParams:(NSDictionary *) params
      completionBlock:(APICompletionBlock)apiCompletionBlock
      dispatcherQueue:(dispatch_queue_t)dispatcherQueue
        requestMethod:(SLRequestMethod) requestMethod

{
    
    
    if(requestMethod == SLRequestMethodGET){
        [self fetchGetFromApi:api withParams:params completionBlock:apiCompletionBlock dispatcherQueue:dispatcherQueue];
    }
    else if(requestMethod == SLRequestMethodGET){
        [self fetchPostFromApi:api withParams:params completionBlock:apiCompletionBlock dispatcherQueue:dispatcherQueue];
    }
    return;
    
    
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {
        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [self.accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [self.accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [self.accountStore accountsWithAccountType:twitterAccountType];
                 
                 NSURL *url = [NSURL URLWithString:[baseApiUrl stringByAppendingString:api]];

                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:requestMethod
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request

                 [request setAccount:[twitterAccounts lastObject]];
                
                 [self someTests:request];
                 
                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                     if (responseData) {
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             NSError *jsonError;
                             NSDictionary *timelineData =
                             [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingAllowFragments error:&jsonError];
                             
                             if (timelineData) {
                                 NSLog(@"Api Response Data for %@ :%@", api,timelineData);
                                 dispatch_async(dispatcherQueue, ^{
                                     apiCompletionBlock(timelineData);
                                 });
                             }
                             else {
                                 // Our JSON deserialization went awry
                                 NSLog(@"JSON Error: %@", [jsonError localizedDescription]);
                             }
                         }
                         else {
                             // The server did not respond successfully... were we rate-limited?
                             NSLog(@"The response status code is %d", urlResponse.statusCode);
                         }
                     }
                 }];
             }
             else {
                 // Access was not granted, or an error occurred
                 NSLog(@"Some error occurred: %@", [error localizedDescription]);
             }
         }];
    } else {
        NSLog(@"User does not have access.");
    }
}

-(void) getCurrentLoggedInUserCompletionBlock:(FetchCurrentUserCompletionBlock)completionBlock
                               dispatcherQueue:(dispatch_queue_t)dispatcherQueue{
    [self fetchCurrentUserCompletionBlock:completionBlock dispatcherQueue:dispatcherQueue];
}

- (void)fetchTimelineForUser:(NSString *)username
             completionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                       maxId:(NSString*) maxId
{
    NSString *api = @"statuses/user_timeline.json";
    
    NSMutableDictionary *params = [@{@"screen_name" : username,
                                   @"include_rts" : @"0",
                                   @"count" : @"50"} mutableCopy];
    
    if(![maxId isEqualToString: @"-1"]){
        params[@"max_id"] = maxId;
    }
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue
         requestMethod:SLRequestMethodGET];
}

- (void)fetchTimelineForUser:(NSString *)username
             completionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                       sinceId:(NSString *)sinceId
{
    NSString *api = @"statuses/user_timeline.json";
    
    NSMutableDictionary *params = [@{@"screen_name" : username,
                                   @"include_rts" : @"0",
                                   @"count" : @"50"} mutableCopy];
    
    if(![sinceId isEqualToString: @"-1"]){
        params[@"since_id"] = sinceId;
    }
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue
         requestMethod:SLRequestMethodGET];
}


- (void)fetchHomeTimelineForCurrentUserCompletionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                                                 maxId:(NSString*) maxId
{
    NSString *api = @"statuses/home_timeline.json";
    NSMutableDictionary *params =  [@{@"include_rts" : @"0",
                                    @"count" : @"20"} mutableCopy];

    if(![maxId isEqualToString: @"-1"]){
        params[@"max_id"] = maxId;
    }
    
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue
         requestMethod:SLRequestMethodGET];
}

- (void)fetchHomeTimelineForCurrentUserCompletionBlock:(APICompletionBlock)apiCompletionBlock
                                       dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                                                 sinceId:(NSString *)sinceId
{
    NSString *api = @"statuses/home_timeline.json";
    NSMutableDictionary *params =  [@{@"include_rts" : @"0",
                                    @"count" : @"20"} mutableCopy];
    
    if(![sinceId isEqualToString: @"-1"]){
        params[@"since_id"] = sinceId;
    }
    
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue
         requestMethod:SLRequestMethodGET];
}

- (void)postTweet:(NSString*)tweet
  completionBlock:(APICompletionBlock)apiCompletionBlock
  dispatcherQueue:(dispatch_queue_t)dispatcherQueue
{
    NSString *api = @"statuses/update.json";
    NSDictionary *params = @{@"status" : tweet};
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue
         requestMethod:SLRequestMethodPOST];
}

- (void)fetchDetailsForUser:(NSString *)username
             completionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
{
    NSString *api = @"users/show.json";
    NSDictionary *params = @{@"screen_name" : username};
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue
         requestMethod:SLRequestMethodGET];
}

- (void)fetchFollowersForUser:(NSString *)username
            completionBlock:(APICompletionBlock)apiCompletionBlock
            dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                   nextCursor:(NSString*)nextCursor
{
    NSString *api = @"followers/list.json";
    NSDictionary *params = @{@"screen_name" : username,
                             @"cursor": nextCursor};
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue
         requestMethod:SLRequestMethodGET];
}

- (void)fetchFollowingForUser:(NSString *)username
              completionBlock:(APICompletionBlock)apiCompletionBlock
              dispatcherQueue:(dispatch_queue_t)dispatcherQueue
                   nextCursor:(NSString*)nextCursor
{
    NSString *api = @"friends/list.json";
    NSDictionary *params = @{@"screen_name" : username,
                             @"cursor": nextCursor};
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue
         requestMethod:SLRequestMethodGET];
}
@end
