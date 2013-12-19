//
//  Utils.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/14/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "Utils.h"

@implementation Utils
#pragma mark Class methods
+ (void)alert:(NSString *)msg {
  [[NSAlert alertWithMessageText:msg
                   defaultButton:nil
                 alternateButton:nil
                     otherButton:nil
       informativeTextWithFormat:@""] runModal];
}

+ (void)alertWithError:(NSError *)error {
  [[NSAlert alertWithError:error] runModal];
}

+ (NSError *)createError:(NSString *)errorStr withErrorCode:(NSInteger)code {
  NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
  [errorDetails setValue:errorStr forKey:NSLocalizedDescriptionKey];
  return [NSError errorWithDomain:ERROR_DOMAIN code:code userInfo:errorDetails];
}

+ (NSError *)createError:(NSString *)errorStr {
  return [Utils createError:errorStr withErrorCode:1];
}
@end
