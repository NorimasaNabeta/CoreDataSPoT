//
//  SPoTDetailTableViewController.h
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/07.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPoTDetailTableViewController : UITableViewController
- (NSString *)titleForRow:(NSUInteger)row;
- (NSString *)subtitleForRow:(NSUInteger)row;

// the Model for this VC
// an array of dictionaries of Flickr information
// obtained using Flickr API
// (e.g. FlickrFetcher will obtain such an array of dictionaries)
@property (nonatomic, strong) NSArray *photos; // of NSDictionary

@end
