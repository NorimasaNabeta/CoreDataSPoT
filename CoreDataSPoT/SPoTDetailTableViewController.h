//
//  SPoTDetailTableViewController.h
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/07.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreDataTableViewController.h"
#import "Photographer.h"

@interface SPoTDetailTableViewController : CoreDataTableViewController

@property (nonatomic, strong) Photographer *photographer;

@end
