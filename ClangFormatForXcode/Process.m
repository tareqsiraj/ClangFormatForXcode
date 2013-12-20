//
//  Process.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/10/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "Process.h"
#import "Utils.h"

@interface Process ()
@property(readwrite) NSString *stdOut;
@property(readwrite) NSString *stdErr;
@end

@implementation Process

@synthesize executable = _executable;
@synthesize stdOut = _stdOut;
@synthesize stdErr = _stdErr;
@synthesize stdIn = _stdIn;
@synthesize params = _params;

- (id)initWithExecutable:(NSString *)exe
                   error:(NSError *__autoreleasing *)error {
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *absolutePath = nil;
  if (![fileManager fileExistsAtPath:exe]) {
    // File does not exist. Look for the file in the PATH env variable.
    NSDictionary *env = [[NSProcessInfo processInfo] environment];
    NSArray *paths =
        [[env objectForKey:@"PATH"] componentsSeparatedByString:@":"];
    BOOL fileNotExecutable = NO;
    // Iterate through the paths in PATH and check if the executable exists and
    // marked as executable.
    for (NSString *path in paths) {
      NSString *checkPath = [path stringByAppendingPathComponent:exe];
      NSLog(@"%@", checkPath);
      if ([fileManager fileExistsAtPath:checkPath]) {
        // Found the path to the executable, now check if its marked executable.
        if ([fileManager isExecutableFileAtPath:checkPath]) {
          absolutePath = [NSString stringWithString:checkPath];
          break;
        } else {
          fileNotExecutable = YES;
        }
      }
    }

    // We either didn't find the file or its not executable.
    if (absolutePath == nil) {
      if (error) {
        NSString *errorStr;
        if (fileNotExecutable)
          errorStr =
              [NSString stringWithFormat:@"%@ is not an executable!", exe];
        else
          errorStr = [NSString stringWithFormat:@"%@ not found in path!", exe];

        *error = [Utils createError:errorStr];
      }
      return nil;
    }
  } else {
    // Path exists
    absolutePath =
        [[exe stringByExpandingTildeInPath] stringByStandardizingPath];
  }

  if (self = [super init]) {
    _executable = [absolutePath copy];
    _stdIn = nil;
    _params = [[NSMutableArray alloc] initWithCapacity:5];
  }
  
  return self;
}

- (BOOL)execute:(NSError *__autoreleasing *)error {
  NSTask *task = [[NSTask alloc] init];
  [task setLaunchPath:[self executable]];
  NSPipe *stdOutPipe = [NSPipe pipe];
  NSPipe *stdErrPipe = [NSPipe pipe];
  NSPipe *stdInPipe = nil;

  [task setArguments:[self params]];
  [task setStandardOutput:stdOutPipe];
  [task setStandardError:stdErrPipe];

  if ([self stdIn] != nil) {
    stdInPipe = [NSPipe pipe];
    [task setStandardInput:stdInPipe];
  }

  @try {
    [task launch];
  }
  @catch (NSException *exception) {
    if (error)
      *error = [Utils createError:[exception reason]];
    return NO;
  }

  if (stdInPipe != nil) {
    NSFileHandle *stdInFileHandle = [stdInPipe fileHandleForWriting];

    [stdInFileHandle
        writeData:[[self stdIn] dataUsingEncoding:NSUTF8StringEncoding]];
    [stdInFileHandle closeFile];
  }

  [task waitUntilExit];

  int status = [task terminationStatus];
  if (status == 0) {
    NSFileHandle *stdOutFileHandle = [stdOutPipe fileHandleForReading];
    NSData *stdOutData = [stdOutFileHandle readDataToEndOfFile];
    [self setStdOut:[[NSString alloc] initWithData:stdOutData
                                          encoding:NSUTF8StringEncoding]];
    return YES;
  } else {
    if (error) {
      NSString *errStr =
          [NSString stringWithFormat:@"'%@' exitted with code %d",
                                     [self executable], status];
      *error = [Utils createError:errStr];
    }
    return NO;
  }
}

- (void)addParams:(NSString *)paramStr {
  [self clearParams];
  // FIXME: Properly split long params with quotes.
  NSArray *paramsArray = [paramStr componentsSeparatedByString:@" "];
  [[self params] addObjectsFromArray:paramsArray];
}

- (void)clearParams {
  [[self params] removeAllObjects];
}

@end