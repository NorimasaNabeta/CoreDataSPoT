//
//  ManagedDocumentHelper.h
//  FortuneTweet
//
//  Created by Norimasa Nabeta on 2012/08/24.
//  Copyright (c) 2012 Norimasa Nabeta. All rights reserved.
//

#import <Foundation/Foundation.h>
#define DATABASE_FILENAME @"SPoTDatabase"

@interface ManagedDocumentHelper : NSObject
//+ (UIManagedDocument *)sharedManagedDocument:(NSString *)name;
+ (UIManagedDocument *)sharedManagedDocument;
+ (void) useDocument:(UIManagedDocument*) document usingBlock:(void (^)(BOOL))block debugComment:(NSString*)comment;

@end
