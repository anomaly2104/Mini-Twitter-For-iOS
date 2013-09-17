//
//  HomeTimeLine.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 17/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet;

@interface HomeTimeLine : NSManagedObject

@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSSet *feeds;
@end

@interface HomeTimeLine (CoreDataGeneratedAccessors)

- (void)addFeedsObject:(Tweet *)value;
- (void)removeFeedsObject:(Tweet *)value;
- (void)addFeeds:(NSSet *)values;
- (void)removeFeeds:(NSSet *)values;

@end
