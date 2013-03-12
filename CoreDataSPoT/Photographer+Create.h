//
//  Photographer+Create.h
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/12.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)
+ (Photographer *)photographerWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;


@end
