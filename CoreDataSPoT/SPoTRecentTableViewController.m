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

#import "ManagedDocumentHelper.h"


@interface SPoTRecentTableViewController ()
@property (nonatomic) UIManagedDocument *sharedDocument;
@end

@implementation SPoTRecentTableViewController

#pragma mark - Properties


- (void)viewDidLoad
{
    [super viewDidLoad];
    // self.debug = YES;
    [self.refreshControl addTarget:self
                            action:@selector(refresh)
                  forControlEvents:UIControlEventValueChanged];
}
// Whenever the table is about to appear, if we have not yet opened/created or demo document, do so.

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [ManagedDocumentHelper useDocument:self.sharedDocument
                            usingBlock: ^(BOOL success){ ; }
                          debugComment:@"BK"];
}

- (UIManagedDocument *) sharedDocument
{
    if (! _sharedDocument) {
        _sharedDocument = ManagedDocumentHelper.sharedManagedDocument;        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Recents"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
        request.predicate = nil; // all Recents
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:_sharedDocument.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    return _sharedDocument;
}
#pragma mark - Refreshing

// Fires off a block on a queue to fetch data from Flickr.
// When the data comes back, it is loaded into Core Data by posting a block to do so on
//   self.managedObjectContext's proper queue (using performBlock:).
// Data is loaded into Core Data by calling photoWithFlickrInfo:inManagedObjectContext: category method.

- (IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    [self.refreshControl endRefreshing];
    /*
     [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        NSArray *photos = [FlickrFetcher latestGeoreferencedPhotos];
        // put the photos in Core Data
        [self.sharedDocument.managedObjectContext performBlock:^{
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.sharedDocument.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
 */
}



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
            Recents *recent = [self.fetchedResultsController objectAtIndexPath:indexPath];
            if ([segue.destinationViewController respondsToSelector:@selector(setImageURL:)]) {
                [segue.destinationViewController performSelector:@selector(setImageURL:)
                                                      withObject:[NSURL URLWithString:recent.photos.imageURL]];
            }
            if ([segue.destinationViewController respondsToSelector:@selector(setTitle:)]) {
                [segue.destinationViewController performSelector:@selector(setTitle:)
                                                      withObject:recent.photos.title];
            }
            
        }
    }
}



@end
