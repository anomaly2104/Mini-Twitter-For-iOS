//
//  Tweet.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 17/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class HomeTimeLine, User;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * tweetMessage;
@property (nonatomic, retain) NSDate * tweetTimestamp;
@property (nonatomic, retain) NSString * tweetId;
@property (nonatomic, retain) User *tweetedBy;
@property (nonatomic, retain) NSSet *inHomeTimeLine;
@end

@interface Tweet (CoreDataGeneratedAccessors)

- (void)addInHomeTimeLineObject:(HomeTimeLine *)value;
- (void)removeInHomeTimeLineObject:(HomeTimeLine *)value;
- (void)addInHomeTimeLine:(NSSet *)values;
- (void)removeInHomeTimeLine:(NSSet *)values;

@end
