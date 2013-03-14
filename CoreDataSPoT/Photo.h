//
//  Photo.h
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/13.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photographer, Recents;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * subtitle;
@property (nonatomic, retain) NSString * unique;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * thumbnailURL;
@property (nonatomic, retain) Photographer *whoTook;
@property (nonatomic, retain) NSSet *whenLook;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addWhenLookObject:(Recents *)value;
- (void)removeWhenLookObject:(Recents *)value;
- (void)addWhenLook:(NSSet *)values;
- (void)removeWhenLook:(NSSet *)values;

@end
