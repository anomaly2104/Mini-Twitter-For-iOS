//
//  ReponseCreator.m
//  Mini Twitter For iOS
//
//  Created by udit.ag on 04/09/13.
//  Copyright (c) 2013 udit.ag. All rights reserved.
//

#import "ResponseCreator.h"

@implementation ResponseCreator
+ (NSDictionary *) createSuccessWithData:(id) data {
    NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
    [response setObject:data forKey:RESPONSE_KEY_DATA];
    [response setObject:RESPONSE_STATUS_OK forKey:RESPONSE_KEY_STATUS];
    return response;
}
+ (NSDictionary *) createErrorWithMessage:(NSString *) message andCustomErrorCode: (NSNumber *) errorCode {
    NSMutableDictionary* response = [[NSMutableDictionary alloc] init];
    [response setObject:message forKey:RESPONSE_KEY_ERROR_MESSAGE];
    [response setObject:errorCode forKey:RESPONSE_KEY_ERROR_CODE];
    [response setObject:RESPONSE_STATUS_ERROR forKey:RESPONSE_KEY_STATUS];
    return response;
}
@end
