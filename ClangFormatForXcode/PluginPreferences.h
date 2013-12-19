//
//  PluginPreferences.h
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/15/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import <Foundation/Foundation.h>

// A class to store the preferences for the plugin.
@interface PluginPreferences : NSObject

// Path to the clang-format executable.
@property(strong) NSString *clangFormatPath;

// The currently selected style.
@property(strong) NSString *selectedStyle;
@end
