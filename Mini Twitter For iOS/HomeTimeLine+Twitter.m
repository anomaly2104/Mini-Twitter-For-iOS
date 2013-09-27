//
//  HomeTimeLine+Twitter.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 17/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "HomeTimeLine+Twitter.h"

@implementation MTHomeTimeLine (Twitter)
+(MTHomeTimeLine*) insertFeedWithFeedData:(NSDictionary*) feedData
                   inHomeTimeLineUserName:(NSString*)userName
                   inManagedObjectContext:(NSManagedObjectContext*) context{
    MTHomeTimeLine* homeTimeLine = nil;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"MTHomeTimeLine"];
    request.predicate = [NSPredicate predicateWithFormat:@"userName = %@", userName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        homeTimeLine = [NSEntityDescription insertNewObjectForEntityForName:@"MTHomeTimeLine" inManagedObjectContext:context];
        homeTimeLine.userName = userName;
        [homeTimeLine addFeedsObject:[MTTweet tweetWithTwitterData:feedData inManagedObjectContext:context]];
    } else {
        homeTimeLine = [matches lastObject];
        [homeTimeLine addFeedsObject:[MTTweet tweetWithTwitterData:feedData inManagedObjectContext:context]];
    }
    return homeTimeLine;
}
@end
