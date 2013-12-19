//
//  Preferences.h
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/12/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import <Foundation/Foundation.h>

// A class to save/load application specific preferences. This class will
// automatically create a directory for the application in
// "~/Library/Application Support" folder. After initialization, this class
// behaves like a proxy object for the application preference and responds to
// messages that the application preference object accepts.
//
// An application can use multiple preference files with different configuration
// names if necessary.
@interface Preferences : NSProxy

// A file URL to the preference file.
@property(readonly, strong) NSURL *appPref;

// The application preference object.
@property(readonly, strong) id configObject;

// Initializer with application name and configuration object. Always call this
// method instead of the default init method, otherwise bad things will happen.
//
// |name| - Name of the application.
// |configName| - Name of the configuration file that will be saved.
//   E.g. foo.plist.
// |configObject| - The application configuration object. Generally this is a
//   very simple object that only provides getters and setters for preferences.
// |error| - The error if there is any.
//
// Returns the initialized object if there is no error, otherwise nil.
- (id)initWithAppName:(NSString *)name
           configName:(NSString *)configName
         configObject:(id)configObject
                error:(NSError *__autoreleasing *)error;

// Loads the preferences from disk.
//
// |error| - The error if there is any.
//
// Returns YES if there is no error, otherwise NO.
- (BOOL)loadPreferences:(NSError *__autoreleasing *)error;

// Saves the preferences from disk.
//
// |error| - The error if there is any.
//
// Retuns YES if there is no error, otherwise NO.
- (BOOL)savePreferences:(NSError *__autoreleasing *)error;

@end
