//
//  SPoTRecentTableViewController.m
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/07.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//
#import "SPoTAppDelegate.h"
#import "SPoTRecentTableViewController.h"
#import "FlickrFetcher.h"


@interface SPoTRecentTableViewController ()

@end

@implementation SPoTRecentTableViewController

#pragma mark - Properties
// Whenever the table is about to appear, if we have not yet opened/created or demo document, do so.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext){
        [self useDemoDocument];
    }
}

// Either creates, opens or just uses the demo document
//   (actually, it will never "just use" it since it just creates the UIManagedDocument instance here;
//    the "just uses" case is just shown that if someone hands you a UIManagedDocument, it might already
//    be open and so you can just use it if it's documentState is UIDocumentStateNormal).
//
// Creating and opening are asynchronous, so in the completion handler we set our Model (managedObjectContext).

- (void)useDemoDocument
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Demo Document"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  // [self refresh];
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
            }
        }];
    } else {
        self.managedObjectContext = document.managedObjectContext;
    }
//    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
//    /// [self useDocument:sharedDocument];
//    [ManagedDocumentHelper useDocument:sharedDocument
//                            usingBlock: ^(BOOL success){
//                                [self setupFetchedResultsController];
//                                [self spinnerAction:NO];
//                            }
//                          debugComment:@"HT"];

}

- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recents"];
        // request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];

        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
        request.predicate = nil; // all Recents
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

//- (void)setupFetchedResultsController
//{
//    UIManagedDocument *sharedDocument = [ManagedDocumentHelper sharedManagedDocumentFortuneTweet];
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"History"];
//    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
//    request.predicate = nil; // all Recents    
//    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
//                                                                        managedObjectContext:sharedDocument.managedObjectContext
//                                                                          sectionNameKeyPath:nil
//                                                                                   cacheName:nil];
//}

#pragma mark - UITableViewDataSource
#pragma mark - Table view data source
#pragma mark - Table view delegate

/*
 */

// Loads up the cell for a given row by getting the associated Photo from our NSFetchedResultsController.

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Recent Photo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    Recents *recent = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = recent.photos.title;
    cell.detailTextLabel.text = recent.photos.subtitle;
    
    id appDelegate = (id)[[UIApplication sharedApplication] delegate];
    NSString *idThumbnail = recent.photos.thumbnailURL;
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
        if ([segue.identifier isEqualToString:@"Show Recent"]) {
            Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                [segue.destinationViewController performSelector:@selector(setImageURL:) withObject:[NSURL URLWithString:photo.imageURL]];
            }
            if ([segue.destinationViewController respondsToSelector:@selector(setTitle:)]) {
                [segue.destinationViewController performSelector:@selector(setTitle:) withObject:photo.title];
            }
            //[RecentsStore pushList:self.photos[indexPath.row]];
            
        }
    }
}



@end
