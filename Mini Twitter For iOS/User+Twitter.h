//
//  User+Twitter.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "MTUser.h"
#import <Accounts/ACAccount.h>
@interface MTUser (Twitter)
-(NSURL*) profileUrl;
+(MTUser*) userWithTwitterData:(NSDictionary*) userTwitterData;
+(MTUser*) userWithTwitterData:(NSDictionary*) userTwitterData
inManagedObjectContext:(NSManagedObjectContext*) context;
+(MTUser*) userWithACAccount:(ACAccount*) acAccount;
//+(User*) userWithACAccount:(ACAccount*) acAccount
//inManagedObjectContext:(NSManagedObjectContext*) context;
@end
