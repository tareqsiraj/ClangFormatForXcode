//
//  Process.h
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/10/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Process : NSObject
@property(copy) NSString *executable;
@property(readonly) NSString *stdOut;
@property(readonly) NSString *stdErr;
@property(strong) NSString *stdIn;
@property(strong) NSMutableArray *params;

- (id)initWithExecutable:(NSString *)exe
                   error:(NSError *__autoreleasing *)error;
- (void)addParams:(NSString *)paramStr;
- (void)clearParams;
- (BOOL)execute:(NSError *__autoreleasing *)error;
@end
