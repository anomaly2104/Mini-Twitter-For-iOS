//
//  User.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet, User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * numberFollowers;
@property (nonatomic, retain) NSString * profileUrlString;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * numberFollowing;
@property (nonatomic, retain) NSNumber * numberTweets;
@property (nonatomic, retain) NSSet *tweet;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *followings;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTweetObject:(Tweet *)value;
- (void)removeTweetObject:(Tweet *)value;
- (void)addTweet:(NSSet *)values;
- (void)removeTweet:(NSSet *)values;

- (void)addFollowersObject:(User *)value;
- (void)removeFollowersObject:(User *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFollowingsObject:(User *)value;
- (void)removeFollowingsObject:(User *)value;
- (void)addFollowings:(NSSet *)values;
- (void)removeFollowings:(NSSet *)values;

@end
