//
//  SPoTDetailTableViewController.m
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/07.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//
#import "SPoTAppDelegate.h"
#import "SPoTDetailTableViewController.h"
#import "FlickrFetcher.h"
// #import "RecentsStore.h"

#import "Photo.h"
#import "Photographer.h"
#import "Recents+Create.h"

@interface SPoTDetailTableViewController () 

@end

@implementation SPoTDetailTableViewController


#pragma mark - Table view data source

#pragma mark - Properties

// When our Model is set here, we update our title to be the Photographer's name
//   and then set up our NSFetchedResultsController to make a request for Photos taken by that Photographer.

- (void)setPhotographer:(Photographer *)photographer
{
    _photographer = photographer;
    self.title = photographer.name;
    [self setupFetchedResultsController];
}

// Creates an NSFetchRequest for Photos sorted by their title where the whoTook relationship = our Model.
// Note that we have the NSManagedObjectContext we need by asking our Model (the Photographer) for it.
// Uses that to build and set our NSFetchedResultsController property inherited from CoreDataTableViewController.

- (void)setupFetchedResultsController
{
    if (self.photographer.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"whoTook = %@", self.photographer];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.photographer.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

#pragma mark - UITableViewDataSource

/*
 */

// Loads up the cell for a given row by getting the associated Photo from our NSFetchedResultsController.

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;

    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSString *idThumbnail = photo.thumbnailURL;
    UIImage *image = [[appDelegate imageCache] objectForKey:idThumbnail];
    if (image) {
        // NSLog(@"HIT user:%@ screen:%@", tweetuser, tweetscreenuser);
        cell.imageView.image = image;
    }
    else {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL URLWithString:idThumbnail];
            NSData *data = [NSData dataWithContentsOfURL:url];
            [[appDelegate imageCache] setObject:[UIImage imageWithData:data] forKey:idThumbnail];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [cell.imageView setImage:[UIImage imageWithData:data]];
                [self.tableView reloadData];
            });
        });
    }
    
    return cell;
    
}

#pragma mark - Segue

// Gets the NSIndexPath of the UITableViewCell which is sender.
// Then uses that NSIndexPath to find the Photographer in question using NSFetchedResultsController.
// Prepares a destination view controller through the "setPhotographer:" segue by sending that to it.

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = nil;
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        indexPath = [self.tableView indexPathForCell:sender];
    }
    
    if (indexPath) {
        if ([segue.identifier isEqualToString:@"Show Image"]) {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
            }
            if ([segue.destinationViewController respondsToSelector:@selector(setTitle:)]) {
                [segue.destinationViewController performSelector:@selector(setTitle:) withObject:photo.title];
            }
            //[RecentsStore pushList:self.photos[indexPath.row]];
            [Recents recentsViewPhoto:photo inManagedObjectContext:photo.managedObjectContext];


        }
    }
}

@end
