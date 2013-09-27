//
//  Tweet.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 17/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MTHomeTimeLine, MTUser;

@interface MTTweet : NSManagedObject

@property (nonatomic, retain) NSString * tweetMessage;
@property (nonatomic, retain) NSDate * tweetTimestamp;
@property (nonatomic, retain) NSString * tweetId;
@property (nonatomic, retain) MTUser *tweetedBy;
@property (nonatomic, retain) NSSet *inHomeTimeLine;
@end

@interface MTTweet (CoreDataGeneratedAccessors)

- (void)addInHomeTimeLineObject:(MTHomeTimeLine *)value;
- (void)removeInHomeTimeLineObject:(MTHomeTimeLine *)value;
- (void)addInHomeTimeLine:(NSSet *)values;
- (void)removeInHomeTimeLine:(NSSet *)values;

@end
