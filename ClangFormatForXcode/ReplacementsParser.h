//
//  ReplacementsParser.h
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/10/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReplacementsParser : NSObject <NSXMLParserDelegate>
@property(strong, readonly) NSMutableArray *replacements;

- (BOOL)applyReplacements:(NSString *)replacementsXML
               inTextView:(NSTextView *)txtView
                    error:(NSError *__autoreleasing *)error;
@end