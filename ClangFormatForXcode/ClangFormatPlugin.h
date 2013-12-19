//
//  ClangFormatPlugin.h
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/9/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "Process.h"

@interface ClangFormatPlugin : NSObject
@property(strong) Process *clangFormat;
@property(strong) id preferences;
@end
