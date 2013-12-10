//
//  Replacement.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/10/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "Replacement.h"

@interface Replacement ()
@property(readwrite) NSMutableString *replacementStr;
@end

@implementation Replacement
@synthesize range = _range;
@synthesize replacementStr = _replacementStr;

- (id)initWithOffset:(NSUInteger)offset
              length:(NSUInteger)length
      replacementStr:(NSString *)str {
  if (self = [super init]) {
    _range.location = offset;
    _range.length = length;
    _replacementStr = [[NSMutableString alloc] initWithString:str];
  }
  return self;
}

- (void)dealloc {
  [_replacementStr release];
  [super dealloc];
}

- (void)appendReplacement:(NSString *)str {
  [[self replacementStr] appendString:str];
}

- (void)eraseLastCharacter {
  NSMutableString *replacementString = [self replacementStr];
  if ([replacementString length] > 0) {
    [[self replacementStr]
        deleteCharactersInRange:NSMakeRange([replacementString length] - 1, 1)];
  }
}

- (NSString *)description {
  return
      [NSString stringWithFormat:@"Offset: %lu Length: %lu Replacement: '%@'",
          [self range].location, [self range].length, [self replacementStr]];
}
@end
