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
    
    
    // if the meaning of 'historical records', all of the viewing event should be insert into the database indipendently.
    // in this case, previous implementation is not wrong.
    // if (photo) {
    //        recent = [NSEntityDescription insertNewObjectForEntityForName:@"Recents" inManagedObjectContext:context];
    //        recent.photos = photo;
    //        recent.timestamp = [[NSDate date] timeIntervalSince1970];
    // }
    // but this implementation does not insert the multiple records for the same photo view event.
    //
    if (photo) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recents"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
        request.predicate = [NSPredicate predicateWithFormat:@"photos.unique = %@", photo.unique];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
        } else if (![matches count]) {
            recent = [NSEntityDescription insertNewObjectForEntityForName:@"Recents" inManagedObjectContext:context];
            recent.photos = photo;
            recent.timestamp = [[NSDate date] timeIntervalSince1970];
        } else {
            recent = [matches lastObject];
        }

    }
    
    
    
    
    return recent;
}

@end
