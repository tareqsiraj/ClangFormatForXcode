//
//  Replacement.h
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/10/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Replacement : NSObject
@property NSRange range;
@property(readonly) NSMutableString *replacementStr;

- (id)initWithOffset:(NSUInteger)offset
              length:(NSUInteger)length
      replacementStr:(NSString *)str;
- (void)appendReplacement:(NSString *)str;
- (void)eraseLastCharacter;
@end
