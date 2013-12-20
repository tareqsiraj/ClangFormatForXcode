//
//  Preferences.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/12/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "Preferences.h"
#import "Utils.h"
#import <objc/runtime.h>

@implementation Preferences

@synthesize appPref = _appPref;
@synthesize configObject = _configObject;

#pragma mark Init functions
- (id)initWithAppName:(NSString *)name
           configName:(NSString *)configName
         configObject:(id)configObject
                error:(NSError *__autoreleasing *)error {
  if (self) {
    _configObject = configObject;
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSArray *paths = [fileManager URLsForDirectory:NSApplicationSupportDirectory
                                         inDomains:NSUserDomainMask];
    NSURL *appPrefDir =
        [[paths objectAtIndex:0] URLByAppendingPathComponent:name
                                                 isDirectory:YES];

    BOOL isDir = NO;
    if (![fileManager fileExistsAtPath:[appPrefDir absoluteString]
                           isDirectory:&isDir]) {
      // This can mean:
      // 1. The directory doesn't exist. Or,
      // 2. The directory isn't accessible from Xcode.
      // We can't do anything for #2, lets try to create the directory.
      if (![fileManager createDirectoryAtURL:appPrefDir
                 withIntermediateDirectories:YES
                                  attributes:nil
                                       error:error]) {
        return nil;
      }
    } else if (!isDir) {
      // For some reason, there is a file with the same name exists in the
      // Application Preferences directory. Just raise an error in this weird
      // situation.
      if (error) {
        NSString *errMsg =
            [NSString stringWithFormat:
                          @"'%@' seems to be a file instead of a directory. "
                           "Please remove this file and restart Xcode to "
                           "allow ClangFormatForXcode to save preferences.",
                appPrefDir];
        *error = [Utils createError:errMsg];
      }
      return nil;
    }

    _appPref = [appPrefDir URLByAppendingPathComponent:configName];

    if (![[self appPref] checkResourceIsReachableAndReturnError:nil]) {
      // Create the default preferences file.
      if (![self savePreferences:error])
        return nil;
    }
  }

  return self;
}

#pragma mark Proxy functions
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  return [[self configObject] methodSignatureForSelector:sel];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
  if ([[self configObject] respondsToSelector:aSelector])
    return YES;
  return NO;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
  [invocation invokeWithTarget:[self configObject]];
}

#pragma mark Instance methods
- (BOOL)loadPreferences:(NSError *__autoreleasing *)error {
  NSDictionary *preferences =
      [[NSDictionary alloc] initWithContentsOfURL:[self appPref]];
  if (preferences == nil) {
    if (error)
      *error = [Utils createError:@"Error loading preferences!"];
    return NO;
  }
  [[self configObject] setValuesForKeysWithDictionary:preferences];
  return YES;
}

- (BOOL)savePreferences:(NSError *__autoreleasing *)error {
  unsigned int numProperties = 0;
  objc_property_t *properties =
      class_copyPropertyList([[self configObject] class], &numProperties);
  NSMutableArray *propArray = [[NSMutableArray alloc] init];
  for (unsigned int i = 0; i < numProperties; ++i) {
    objc_property_t property = properties[i];
    const char *name = property_getName(property);
    [propArray addObject:[NSString stringWithUTF8String:name]];
  }
  free(properties);

  NSDictionary *preferences =
      [[self configObject] dictionaryWithValuesForKeys:propArray];
  if (![preferences writeToURL:[self appPref] atomically:YES]) {
    if (error)
      *error = [Utils createError:@"Failed to write preferences!"];
    return NO;
  }
  return YES;
}
@end
