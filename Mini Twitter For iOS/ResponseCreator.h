//
//  ReponseCreator.h
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RESPONSE_KEY_DATA @"data"
#define RESPONSE_KEY_STATUS @"status"
#define RESPONSE_KEY_ERROR_MESSAGE @"errormessage"
#define RESPONSE_KEY_ERROR_CODE @"errorcode"

#define RESPONSE_STATUS_OK @"ok"
#define RESPONSE_STATUS_ERROR @"error"

@interface ResponseCreator : NSObject
+ (NSDictionary *) createSuccessWithData:(NSObject *) data;
+ (NSDictionary *) createErrorWithMessage:(NSString *) message andCustomErrorCode: (NSNumber *) errorCode;
@end
