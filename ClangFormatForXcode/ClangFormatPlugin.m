//
//  ClangFormatPlugin.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/9/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "ClangFormatPlugin.h"
#import "ReplacementsParser.h"

@implementation ClangFormatPlugin

@synthesize clangFormat = _clangFormat;

static ClangFormatPlugin *plugin = nil;
//FIXME: Make the path selectable by the user
static NSString *clangFormatExecutablePath = @"/opt/clang/bin/clang-format";

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
    NSError *error = nil;
    _clangFormat = [[Process alloc] initWithExecutable:clangFormatExecutablePath
                                                 error:&error];
    if (error != nil) {
      [[NSAlert alertWithMessageText:[error description]
                       defaultButton:@"OK"
                     alternateButton:nil
                         otherButton:nil
           informativeTextWithFormat:@""] runModal];
      return self;
    }
    [self addClangFormatMenuToEditMenu];
  }
  return self;
}

-(void) dealloc {
  [_clangFormat release];
  [super dealloc];
}

#pragma mark Menu related methods
- (void)addClangFormatMenuToEditMenu {
  NSMenu *mainMenu = [NSApp mainMenu];
  NSMenuItem *editMenuItem = [mainMenu itemWithTitle:@"Edit"];
  if (editMenuItem) {
    NSMenuItem *clangFormatMenuItem =
        [[[NSMenuItem alloc] initWithTitle:@"Clang Format"
                                    action:@selector(menuActionNoOp:)
                             keyEquivalent:@""] autorelease];
    [clangFormatMenuItem setTarget:self];
    [[editMenuItem submenu] addItem:clangFormatMenuItem];

    NSMenu *clangFormatSubMenu = [[[NSMenu alloc] init] autorelease];
    [clangFormatMenuItem setSubmenu:clangFormatSubMenu];

    NSMenuItem *cfFormatSelected =
        [[[NSMenuItem alloc] initWithTitle:@"Format Selected Text"
                                    action:@selector(menuActionFormatSelected:)
                             keyEquivalent:@"X"] autorelease];

    [cfFormatSelected setTarget:self];
    [clangFormatSubMenu addItem:cfFormatSelected];
  }
}

- (void)menuActionNoOp:(id)sender {
}

- (void)menuActionFormatSelected:(id)sender {
  NSResponder *firstResponder = [[NSApp keyWindow] firstResponder];

  NSTextView *sourceView = (NSTextView *)firstResponder;
  if (!sourceView) {
    // NSLog(@"menuActionFormatSelected: invalid source view!");
    // TODO: Show error
    return;
  }

  NSArray *currentSelectedRanges = [sourceView selectedRanges];

  NSValue *rangeValue = (NSValue *)[currentSelectedRanges objectAtIndex:0];
  NSRange selectedRange = [rangeValue rangeValue];
  NSString *params =
      [NSString
          stringWithFormat:@"-offset %lu -length %lu -output-replacements-xml",
          selectedRange.location, selectedRange.length];
  NSString *inputText = [sourceView string];

  [[self clangFormat] addParams:params];
  [[self clangFormat] setStdIn:inputText];
  NSError *error = nil;
  [[self clangFormat] execute:&error];

  if (error != nil) {
    [[NSAlert alertWithMessageText:[error localizedDescription]
                     defaultButton:@"OK"
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:@""] runModal];
    return;
  }

  ReplacementsParser *replacements =
      [[[ReplacementsParser alloc] init] autorelease];
  error = nil;
  if (![replacements applyReplacements:[[self clangFormat] stdOut]
                            inTextView:sourceView
                                 error:&error]) {
    [[NSAlert alertWithMessageText:[error localizedDescription]
                     defaultButton:@"OK"
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:@""] runModal];
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
