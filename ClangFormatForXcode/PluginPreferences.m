//
//  PluginPreferences.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/15/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "PluginPreferences.h"

@implementation PluginPreferences
@synthesize clangFormatPath = _clangFormatPath;
@synthesize selectedStyle = _selectedStyle;

- (id)init {
  if (self = [super init]) {
    // Set the default values
    _clangFormatPath = @"/opt/clang/bin/clang-format";
    _selectedStyle = @"LLVM";
  }
  return self;
}
@end
