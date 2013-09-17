//
//  HomeTimeLine+Twitter.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 17/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "HomeTimeLine+Twitter.h"

@implementation HomeTimeLine (Twitter)
+(HomeTimeLine*) insertFeedWithFeedData:(NSDictionary*) feedData
inHomeTimeLineUserName:(NSString*)userName
inManagedObjectContext:(NSManagedObjectContext*) context{
    HomeTimeLine* homeTimeLine = nil;
    NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:@"HomeTimeLine"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"userName = %@", userName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"userName" ascending:YES];
    request.sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
        // handle error
    } else if ([matches count] == 0) {
        homeTimeLine = [NSEntityDescription insertNewObjectForEntityForName:@"HomeTimeLine" inManagedObjectContext:context];
        homeTimeLine.userName = userName;
        [homeTimeLine addFeedsObject:[Tweet tweetWithTwitterData:feedData inManagedObjectContext:context]];
    } else {
        homeTimeLine = [matches lastObject];
        [homeTimeLine addFeedsObject:[Tweet tweetWithTwitterData:feedData inManagedObjectContext:context]];
    }
    return homeTimeLine;
}
@end
