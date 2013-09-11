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

- (id)init
{
    self = [super init];
    if (self) {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return self;
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

- (void) fetchFromApi:(NSString *)api withParams:(NSDictionary *) params
      completionBlock:(APICompletionBlock)apiCompletionBlock
      dispatcherQueue:(dispatch_queue_t)dispatcherQueue
{
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
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];
                 
                 //  Attach an account to the request

                 [request setAccount:[twitterAccounts lastObject]];
                 
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
{
    NSString *api = @"statuses/user_timeline.json";
    NSDictionary *params = @{@"screen_name" : username,
                             @"include_rts" : @"0",
                             @"count" : @"50"};
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}

- (void)fetchHomeTimelineForCurrentUserCompletionBlock:(APICompletionBlock)apiCompletionBlock
             dispatcherQueue:(dispatch_queue_t)dispatcherQueue
{
    NSString *api = @"statuses/home_timeline.json";
    NSDictionary *params = @{@"include_rts" : @"0",
                             @"count" : @"10"};
    [self fetchFromApi:api withParams:params
       completionBlock:apiCompletionBlock
       dispatcherQueue:dispatcherQueue];
}
@end
