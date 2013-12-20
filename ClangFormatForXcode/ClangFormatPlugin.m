//
//  ClangFormatPlugin.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/9/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "ClangFormatPlugin.h"
#import "ReplacementsParser.h"
#import "PluginPreferences.h"
#import "Preferences.h"
#import "Utils.h"

@interface ClangFormatPlugin ()
@property(strong) NSMutableDictionary *formatStyles;
@end

@implementation ClangFormatPlugin

@synthesize clangFormat = _clangFormat;
@synthesize preferences = _preferences;
@synthesize formatStyles = _formatStyles;

static ClangFormatPlugin *plugin = nil;

#pragma mark onload, constructor, destructor
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
    _formatStyles = [NSMutableDictionary dictionary];
    [[self formatStyles] insertValue:[NSNull null] inPropertyWithKey:@"LLVM"];
    [[self formatStyles] insertValue:[NSNull null] inPropertyWithKey:@"Google"];
    [[self formatStyles] insertValue:[NSNull null]
                   inPropertyWithKey:@"Chromium"];
    [[self formatStyles] insertValue:[NSNull null]
                   inPropertyWithKey:@"Mozilla"];
    [[self formatStyles] insertValue:[NSNull null] inPropertyWithKey:@"Webkit"];

    NSError *error = nil;
    _preferences =
        [[Preferences alloc] initWithAppName:@"ClangFormatForXcode"
                                  configName:@"ClangFormatForXcode.plist"
                                configObject:[[PluginPreferences alloc] init]
                                       error:&error];
    if ([self preferences] == nil) {
      [Utils alertWithError:error];
      return nil;
    }

    [[self preferences] loadPreferences:&error];

    _clangFormat =
        [[Process alloc] initWithExecutable:[[self preferences] clangFormatPath]
                                      error:&error];
    if (!_clangFormat) {
      [Utils alertWithError:error];
      return nil;
    }

    [self addClangFormatMenuToEditMenu];

    // Select the style saved in preferences
    NSMenuItem *menu =
        [[self formatStyles] objectForKey:[[self preferences] selectedStyle]];
    [menu setState:NSOnState];
  }
  return self;
}

#pragma mark Menu related methods
- (void)addClangFormatMenuToEditMenu {
  NSMenu *mainMenu = [NSApp mainMenu];
  NSMenuItem *editMenuItem = [mainMenu itemWithTitle:@"Edit"];
  if (editMenuItem) {
    NSMenuItem *clangFormatMenuItem =
        [[NSMenuItem alloc] initWithTitle:@"Clang Format"
                                   action:@selector(menuActionNoOp:)
                            keyEquivalent:@""];
    [clangFormatMenuItem setTarget:self];
    [[editMenuItem submenu] addItem:clangFormatMenuItem];

    NSMenu *clangFormatSubMenu = [[NSMenu alloc] init];
    [clangFormatMenuItem setSubmenu:clangFormatSubMenu];

    NSMenuItem *cfFormatSelected =
        [[NSMenuItem alloc] initWithTitle:@"Format Selected Text"
                                   action:@selector(menuActionFormatSelected:)
                            keyEquivalent:@"X"];

    [cfFormatSelected setTarget:self];
    [clangFormatSubMenu addItem:cfFormatSelected];

    NSMenuItem *cfSelectedStyle =
        [[NSMenuItem alloc] initWithTitle:@"Format Style"
                                   action:@selector(menuActionNoOp:)
                            keyEquivalent:@""];
    [cfSelectedStyle setTarget:self];
    [clangFormatSubMenu addItem:cfSelectedStyle];

    NSMenu *cfStyleSubMenu = [[NSMenu alloc] init];
    [cfSelectedStyle setSubmenu:cfStyleSubMenu];

    [[self formatStyles] enumerateKeysAndObjectsUsingBlock:^(id key,
                                                             id obj,
                                                             BOOL *stop) {
      NSMenuItem *item =
          [[NSMenuItem alloc] initWithTitle:key
                                     action:@selector(menuActionSelectStyle:)
                              keyEquivalent:@""];
      [item setTarget:self];
      [cfStyleSubMenu addItem:item];
      [[self formatStyles] setObject:item forKey:key];
    }];
  }
}

- (void)menuActionNoOp:(id)sender {
}

- (void)menuActionSelectStyle:(id)sender {
  NSMenuItem *oldStyle =
      [[self formatStyles] objectForKey:[[self preferences] selectedStyle]];

  // Save the new style in preferences
  [[self preferences] setSelectedStyle:[sender title]];
  NSError *error = nil;
  if (![[self preferences] savePreferences:&error]) {
    [Utils alertWithError:error];
    return;
  }

  [oldStyle setState:NSOffState];
  [sender setState:NSOnState];
}

- (void)menuActionFormatSelected:(id)sender {
  NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];

  NSTextView *sourceView = (NSTextView *)firstResponder;
  if (!sourceView) {
    [Utils alert:@"Invalid source view!"];
    return;
  }

  NSArray *currentSelectedRanges = [sourceView selectedRanges];

  NSValue *rangeValue = (NSValue *)[currentSelectedRanges objectAtIndex:0];
  NSRange selectedRange = [rangeValue rangeValue];
  NSString *params = [NSString
      stringWithFormat:
          @"-offset %lu -length %lu -output-replacements-xml -style %@",
          selectedRange.location, selectedRange.length,
          [[self preferences] selectedStyle]];
  NSString *inputText = [sourceView string];

  [[self clangFormat] addParams:params];
  [[self clangFormat] setStdIn:inputText];
  NSError *error = nil;
  [[self clangFormat] execute:&error];

  if (error != nil) {
    [Utils alertWithError:error];
    return;
  }

  ReplacementsParser *replacements = [[ReplacementsParser alloc] init];
  error = nil;
  if (![replacements applyReplacements:[[self clangFormat] stdOut]
                            inTextView:sourceView
                                 error:&error]) {
    [Utils alertWithError:error];
    return;
  }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
  if ([menuItem action] == @selector(menuActionFormatSelected:)) {
    // Disable the 'Format Selected Text' menu item if the focus was not on the
    // source.
    NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];
    return
        [firstResponder isKindOfClass:NSClassFromString(@"DVTSourceTextView")];
  }
  return YES;
}

@end
