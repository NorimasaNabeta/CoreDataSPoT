//
//  SPoTImageViewController.m
//  CoreDataSPoT
//
//  Created by Norimasa Nabeta on 2013/03/07.
//  Copyright (c) 2013年 CS193p. All rights reserved.
//

#import "SPoTImageViewController.h"

@interface SPoTImageViewController  () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activeIndicator;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation SPoTImageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

// fetches the data from the URL
// turns it into an image
// adjusts the scroll view's content size to fit the image
// sets the image as the image view's image


/*
 NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
 NSData *data = [NSData dataWithContentsOfURL:url];
 
 
 id appDelegate = (id)[[UIApplication sharedApplication] delegate];
 NSString *idThumbnail = [FlickrFetcher stringValueFromKey:photo nameKey:FLICKR_PHOTO_ID];
 UIImage *image = [[appDelegate imageCache] objectForKey:idThumbnail];
 if (image) {
 // NSLog(@"HIT user:%@ screen:%@", tweetuser, tweetscreenuser);
 cell.imageView.image = image;
 }
 else {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
 NSURL *url = [FlickrFetcher urlForPhoto:photo format:FlickrPhotoFormatSquare];
 NSData *data = [NSData dataWithContentsOfURL:url];
 [[appDelegate imageCache] setObject:[UIImage imageWithData:data] forKey:idThumbnail];
 dispatch_sync(dispatch_get_main_queue(), ^{
 [cell.imageView setImage:[UIImage imageWithData:data]];
 [self.tableView reloadData];
 });
 });
 }
 */

- (void)resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        [self.activeIndicator startAnimating];
        
        dispatch_queue_t downloadQueue = dispatch_queue_create("image downloader", NULL);
        dispatch_async(downloadQueue, ^{
            
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:self.imageURL];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.scrollView.zoomScale = 1.0;
                    self.scrollView.contentSize = image.size; //
                    self.imageView.image = image;
                    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                });
            }
            [self.activeIndicator stopAnimating];
        });
    }
}

// lazy instantiation

- (UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

// returns the view which will be zoomed when the user pinches
// in this case, it is the image view, obviously
// (there are no other subviews of the scroll view in its content area)

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
