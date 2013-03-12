//
//  SPoTDetailTableViewController.m
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/07.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "SPoTDetailTableViewController.h"
#import "FlickrFetcher.h"
#import "RecentsStore.h"

#import "Photo.h"
#import "Photographer.h"


@interface SPoTDetailTableViewController () <UISplitViewControllerDelegate>

@end

@implementation SPoTDetailTableViewController

#pragma mark - UISplitViewControllerDelegate

- (void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return NO; // never hide it.
    //    return UIInterfaceOrientationIsPortrait(orientation);
}


#pragma mark - Table view data source

//- (void)setPhotos:(NSArray *)photos
//{
//    _photos = photos;
//    
//    [self.tableView reloadData];
//}


//#pragma mark - UITableViewDataSource
//
//// lets the UITableView know how many rows it should display
//// in this case, just the count of dictionaries in the Model's array
//
//- (NSInteger)tableView:(UITableView *)tableView
// numberOfRowsInSection:(NSInteger)section
//{
//    return [self.photos count];
//}
//
//// a helper method that looks in the Model for the photo dictionary at the given row
////  and gets the title out of it
//
//- (NSString *)titleForRow:(NSUInteger)row
//{
//    return [self.photos[row][FLICKR_PHOTO_TITLE] description]; // description because could be NSNull
//}
//
//// a helper method that looks in the Model for the photo dictionary at the given row
////  and gets the owner of the photo out of it
//
//- (NSString *)subtitleForRow:(NSUInteger)row
//{
//    //    return [self.photos[row][FLICKR_PHOTO_OWNER] description]; // description because could be NSNull
//    // NOT objectForKey: FLICKR_PHOTO_DESCRIPTION is @"description._content"
//    return [self.photos[row] valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
//    
//}
//
//// loads up a table view cell with the title and owner of the photo at the given row in the Model
//
//- (UITableViewCell *)tableView:(UITableView *)tableView
//         cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Flickr Photo";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
//                                                            forIndexPath:indexPath];
//    
//    // Configure the cell...
//    cell.textLabel.text = [self titleForRow:indexPath.row];
//    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
//    
//    return cell;
//}


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

// Loads up the cell for a given row by getting the associated Photo from our NSFetchedResultsController.

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = photo.title;
    cell.detailTextLabel.text = photo.subtitle;
    
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
        }
    }
}

@end
