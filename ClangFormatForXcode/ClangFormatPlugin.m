//
//  ClangFormatPlugin.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/9/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "ClangFormatPlugin.h"

@implementation ClangFormatPlugin

static ClangFormatPlugin *plugin = nil;

+ (void)pluginDidLoad:(NSBundle *)bundle {
  NSBundle *app = [NSBundle mainBundle];
  NSString *bundleIdentifier = [app bundleIdentifier];
  // Load only for Xcode
  if (![bundleIdentifier isEqualToString:@"com.apple.dt.Xcode"])
    return;

  NSLog(@"Clang Format plugin for Xcode loaded");

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ plugin = [[self alloc] init]; });
}

- (id)init {
  if (self = [super init]) {
    [[NSAlert alertWithMessageText:@"Clang Format for Xcode loaded!"
                     defaultButton:@"OK"
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:@""] runModal];
  }
  return self;
}

@end
