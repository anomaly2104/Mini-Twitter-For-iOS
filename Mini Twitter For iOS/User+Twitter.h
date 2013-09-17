//
//  User+Twitter.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 16/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "User.h"
#import <Accounts/ACAccount.h>
@interface User (Twitter)
-(NSURL*) profileUrl;
+(User*) userWithTwitterData:(NSDictionary*) userTwitterData;
+(User*) userWithTwitterData:(NSDictionary*) userTwitterData
inManagedObjectContext:(NSManagedObjectContext*) context;
+(User*) userWithACAccount:(ACAccount*) acAccount;
//+(User*) userWithACAccount:(ACAccount*) acAccount
//inManagedObjectContext:(NSManagedObjectContext*) context;
@end
