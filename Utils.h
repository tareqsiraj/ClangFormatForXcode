//
//  Utils.h
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/14/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import <Foundation/Foundation.h>

#define ERROR_DOMAIN @"com.tasiraj.ClangFormatForXcode"

// Utility class that provides useful helpers.
@interface Utils : NSObject

// Pop an alert dialog.
//
// |msg| - The message to alert with.
+ (void)alert:(NSString *)msg;

// Pop an alert dialog with an error.
//
// |error| - The error object to alert with.
+ (void)alertWithError:(NSError *)error;

// Creates an error object.
//
// |errorStr| - The error string.
// |code| - The error code.
//
// Returns the created NSError object.
+ (NSError *)createError:(NSString *)errorStr;
+ (NSError *)createError:(NSString *)errorStr withErrorCode:(NSInteger)code;
@end
