//
//  User+Twitter.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTUser+Twitter.h"
#import "TweeterFetcher.h"

@implementation MTUser (TwitterAdditions)
-(NSURL*) profileUrl{
    return [NSURL URLWithString:self.profileUrlString];
}
+(MTUser*) userWithTwitterData:(NSDictionary *)userTwitterData inManagedObjectContext:(NSManagedObjectContext *)context{

    MTUser* user = nil;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"MTUser"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"(userName = %@) OR (userId = %@)", [userTwitterData valueForKey:TWITTER_USER_USERNAME],[userTwitterData valueForKey:TWITTER_USER_ID_STR]];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else {
        if ([matches count] == 0) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"MTUser" inManagedObjectContext:context];
        } else {
            user = [matches lastObject];
        }
        
        user.profileUrlString = [userTwitterData valueForKey:TWITTER_USER_PROFILE_IMAGE_URL];
        user.name = [userTwitterData valueForKey:TWITTER_USER_NAME];
        user.userId = [userTwitterData valueForKey:TWITTER_USER_ID_STR];
        user.userName = [userTwitterData valueForKey:TWITTER_USER_USERNAME];
        user.numberTweets = [userTwitterData valueForKey:TWITTER_USER_TWEETS_COUNT];
        user.numberFollowers = [userTwitterData valueForKey:TWITTER_USER_FOLLOWERS_COUNT];
        user.numberFollowing = [userTwitterData valueForKey:TWITTER_USER_FOLLOWING_COUNT];
    }
    return user;
}

/*
+(User*) userWithTwitterData:(NSDictionary*) userTwitterData{
    User *user = nil;
    user= [[User alloc] init];
    user.profileUrlString = [userTwitterData valueForKey:TWITTER_USER_PROFILE_IMAGE_URL];
    user.name = [userTwitterData valueForKey:TWITTER_USER_NAME];
    user.userId = [userTwitterData valueForKey:TWITTER_USER_ID];
    user.userName = [userTwitterData valueForKey:TWITTER_USER_USERNAME];
    user.numberTweets = [userTwitterData valueForKey:TWITTER_USER_TWEETS_COUNT];
    user.numberFollowers = [userTwitterData valueForKey:TWITTER_USER_FOLLOWERS_COUNT];
    user.numberFollowing = [userTwitterData valueForKey:TWITTER_USER_FOLLOWING_COUNT];
    return user;
}
+(User*) userWithACAccount:(ACAccount*) acAccount{
    User* user = [[User alloc] init];
    user.userName = acAccount.username;
    user.userId = [[acAccount valueForKey:@"properties"] valueForKey:@"user_id"];
    return user;
}*/
@end
