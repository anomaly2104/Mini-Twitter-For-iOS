//
//  User+Twitter.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "User+Twitter.h"
#import "TweeterFetcher.h"

@implementation User (Twitter)
-(NSURL*) profileUrl{
    return [NSURL URLWithString:self.profileUrlString];
}
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
@end
