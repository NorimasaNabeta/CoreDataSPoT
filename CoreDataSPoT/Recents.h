//
//  Recents.h
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/13.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Recents : NSManagedObject

@property (nonatomic) NSTimeInterval timestamp;
@property (nonatomic, retain) Photo *photos;

@end
