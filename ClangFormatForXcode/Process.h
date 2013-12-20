//
//  Process.h
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/10/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import <Foundation/Foundation.h>

// A class to execute processes.
@interface Process : NSObject

// Path to the executable
@property(copy) NSString *executable;

// Contents of stdout. This will be filled with contents of stdout (if any)
// after execution finishes.
@property(readonly) NSString *stdOut;

// Contents of stderr. This will be filled with contents of stderr (if any)
// after execution finishes.
@property(readonly) NSString *stdErr;

// Contents of stdin. Fill this up before calling the execute method.
@property(strong) NSString *stdIn;

// Parameters to pass to the executable.
@property(strong) NSMutableArray *params;

// Init method.
//
// |exe| - The executable.
// |error| - The error if there is any.
//
// Returns the initialized object if there is no error, otherwise nil.
- (id)initWithExecutable:(NSString *)exe
                   error:(NSError *__autoreleasing *)error;

// Adds parameters to the executable. Note that this method clears previously
// added parameters.
//
// |paramStr| - The list of parameters as a string.
- (void)addParams:(NSString *)paramStr;

// Clears the existing parameters.
- (void)clearParams;

// Execute the process.
//
// |error| - The error if there is any.
//
// Retuns YES if there is no error, otherwise NO.
- (BOOL)execute:(NSError *__autoreleasing *)error;
@end
