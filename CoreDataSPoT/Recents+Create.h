//
//  Recents+Create.h
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/13.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "Recents.h"

@interface Recents (Create)

+ (Recents *)recentsViewPhoto:(Photo *) photo
                inManagedObjectContext:(NSManagedObjectContext *)context;

@end
