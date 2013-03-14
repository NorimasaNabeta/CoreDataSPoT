//
//  Recents+Create.m
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/13.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "Recents+Create.h"
#import "Photo.h"

@implementation Recents (Create)

+ (Recents *)recentsViewPhoto:(Photo *)photo
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    Recents *recent=nil;
    
    if (photo) {
        // NSArray *matches = [context executeFetchRequest:request error:&error];
        recent = [NSEntityDescription insertNewObjectForEntityForName:@"Recents" inManagedObjectContext:context];
        recent.photos = photo;
        recent.timestamp = [[NSDate date] timeIntervalSince1970];
    }
    
    return recent;
}

@end
