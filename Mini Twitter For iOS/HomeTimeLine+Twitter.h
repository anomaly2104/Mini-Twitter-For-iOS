//
//  HomeTimeLine+Twitter.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 17/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTHomeTimeLine.h"
#import "MTTweet+Twitter.h"
@interface MTHomeTimeLine (Twitter)
+(MTHomeTimeLine*) insertFeedWithFeedData:(NSDictionary*) feedData
                   inHomeTimeLineUserName:(NSString*)userName
                   inManagedObjectContext:(NSManagedObjectContext*) context;
@end
