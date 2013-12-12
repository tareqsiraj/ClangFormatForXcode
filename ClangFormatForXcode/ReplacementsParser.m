//
//  ReplacementsParser.m
//  ClangFormatForXcode
//
//  Created by Tareq A. Siraj on 12/10/2013.
//  Copyright (c) 2013 Tareq A. Siraj. All rights reserved.
//

#import "ReplacementsParser.h"
#import "Replacement.h"

@implementation ReplacementsParser
@synthesize replacements = _replacements;

- (id)init {
  if (self = [super init]) {
    _replacements = [[NSMutableArray alloc] init];
  }

  return self;
}

- (BOOL)applyReplacements:(NSString *)replacementsXML
               inTextView:(NSTextView *)txtView
                    error:(NSError **)error {
  NSXMLParser *parser = [[NSXMLParser alloc]
      initWithData:[replacementsXML dataUsingEncoding:NSUTF8StringEncoding]];
  [parser setShouldProcessNamespaces:NO];
  [parser setShouldReportNamespacePrefixes:NO];
  [parser setShouldResolveExternalEntities:NO];
  [parser setDelegate:self];
  [parser parse];

  NSMutableArray *replacementRanges =
      [[NSMutableArray alloc] initWithCapacity:[[self replacements] count]];
  NSMutableArray *replacementStrings =
      [[NSMutableArray alloc] initWithCapacity:[[self replacements] count]];

  // FIXME: Can we avoid creating Replacement objects and directly populate the
  // following arrays?
  if ([[self replacements] count] > 0) {
    for (Replacement *r in [self replacements]) {
      // FIXME: For some reason, there is a new line at the end of the string.
      // Figure out where its coming from.
      [r eraseLastCharacter];
      [replacementRanges addObject:[NSValue valueWithRange:[r range]]];
      [replacementStrings addObject:[r replacementStr]];
    }

    if ([txtView shouldChangeTextInRanges:replacementRanges
                       replacementStrings:replacementStrings]) {
      [txtView setSelectedRange:NSMakeRange([[txtView string] length], 0)];
      [[txtView textStorage] beginEditing];
      NSInteger locationShift = 0;
      for (Replacement *r in [self replacements]) {
        [[txtView textStorage] replaceCharactersInRange:NSMakeRange(
            [r range].location + locationShift, [r range].length)
                                             withString:[r replacementStr]];
        locationShift += [[r replacementStr] length] - [r range].length;
      }
      [[txtView textStorage] endEditing];
    }
  }

  return YES;
}

#pragma mark Delegate calls
- (void)parser:(NSXMLParser *)parser
    didStartElement:(NSString *)elementName
       namespaceURI:(NSString *)namespaceURI
      qualifiedName:(NSString *)qName
         attributes:(NSDictionary *)attributeDict {
  if ([elementName isEqualToString:@"replacement"]) {
    NSString *offset = [attributeDict objectForKey:@"offset"];
    NSString *length = [attributeDict objectForKey:@"length"];
    Replacement *replacement =
        [[Replacement alloc] initWithOffset:[offset integerValue]
                                     length:[length integerValue]
                             replacementStr:@""];
    [[self replacements] addObject:replacement];
  }
}

- (void)parser:(NSXMLParser *)parser
    didEndElement:(NSString *)elementName
     namespaceURI:(NSString *)namespaceURI
    qualifiedName:(NSString *)qName {
  // FIXME: Don't need this method
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
  Replacement *lastReplacement = [[self replacements] lastObject];
  [lastReplacement appendReplacement:string];
}
@end
