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

- (NSURL *)profileUrl {
    return [NSURL URLWithString:self.profileUrlString];
}

+ (NSPredicate *)predicateForUserName:(NSString *)userName userId:(NSString *)userId {
    if (userName && userId) {
        return [NSPredicate predicateWithFormat:@"(userName = %@) OR (userId = %@)", userName, userId];
    } else if (userName) {
        return [NSPredicate predicateWithFormat:@"(userName = %@)", userName];
    } else if (userId) {
        return [NSPredicate predicateWithFormat:@"(userId = %@)", userId];
    } else {
        return nil;
    }
}

+ (void)populateUser:(MTUser *)user withUserData:(NSDictionary *)userTwitterData {
    if ([userTwitterData valueForKey:TWITTER_USER_PROFILE_IMAGE_URL]) {
        user.profileUrlString = [userTwitterData valueForKey:TWITTER_USER_PROFILE_IMAGE_URL];
    }
    if ([userTwitterData valueForKey:TWITTER_USER_NAME]) {
        user.name = [userTwitterData valueForKey:TWITTER_USER_NAME];
    }
    if ([userTwitterData valueForKey:TWITTER_USER_ID_STR]) {
        user.userId = [userTwitterData valueForKey:TWITTER_USER_ID_STR];
    }
    if ([userTwitterData valueForKey:TWITTER_USER_USERNAME]) {
        user.userName = [userTwitterData valueForKey:TWITTER_USER_USERNAME];
    }
    if ([userTwitterData valueForKey:TWITTER_USER_TWEETS_COUNT]) {
        user.numberTweets = [userTwitterData valueForKey:TWITTER_USER_TWEETS_COUNT];
    }
    if ([userTwitterData valueForKey:TWITTER_USER_FOLLOWERS_COUNT]) {
        user.numberFollowers = [userTwitterData valueForKey:TWITTER_USER_FOLLOWERS_COUNT];
    }
    if ([userTwitterData valueForKey:TWITTER_USER_FOLLOWING_COUNT]) {
        user.numberFollowing = [userTwitterData valueForKey:TWITTER_USER_FOLLOWING_COUNT];
    }
}

+ (NSFetchRequest *)fetchRequestForUserName:(NSString *)userName userId:(NSString *)userId {
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"MTUser"];
    NSPredicate *predicate = [self predicateForUserName:userName userId:userId];
    if (predicate) {
        request.predicate = predicate;
    } else {
        return nil;
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    return request;
}

+ (MTUser *)userWithTwitterData:(NSDictionary *)userTwitterData
         inManagedObjectContext:(NSManagedObjectContext *)context {
    NSFetchRequest *request = [self fetchRequestForUserName:[userTwitterData valueForKey:TWITTER_USER_USERNAME]
                                                     userId:[userTwitterData valueForKey:TWITTER_USER_ID_STR]];
    if (!request) {
        return nil;
    }
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];

    MTUser* user = nil;
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else {
        if ([matches count] == 0) {
            user = [NSEntityDescription insertNewObjectForEntityForName:@"MTUser" inManagedObjectContext:context];
        } else {
            user = [matches lastObject];
        }
        [self populateUser:user withUserData:userTwitterData];
    }
    return user;
}
@end
