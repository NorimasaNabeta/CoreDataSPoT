//
//  Photo+Flickr.h
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/12.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

// Creates a Photo in the database for the given Flickr photo (if necessary).

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
