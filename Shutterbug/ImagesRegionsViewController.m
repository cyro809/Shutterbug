//
//  ImagesPlacesViewController.m
//  Shutterbug
//
//  Created by Cyro Guimaraes on 11/15/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "ImagesRegionsViewController.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"
#import "Helpers.h"

@interface ImagesRegionsViewController ()



@end

@implementation ImagesRegionsViewController

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self.tableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchPhotos];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fetchPhotos
{
    [self.refreshControl beginRefreshing]; // start the spinner
    [self.tableView setContentOffset:CGPointMake(0, -self.refreshControl.frame.size.height) animated:YES];
    NSURL *url = [FlickrFetcher URLforPhotosInPlace:[self.region valueForKeyPath:FLICKR_PLACE_ID] maxResults:50];
    // create a (non-main) queue to do fetch on
    dispatch_queue_t fetchQ = dispatch_queue_create("flickr fetcher", NULL);
    // put a block to do the fetch onto that queue
    dispatch_async(fetchQ, ^{
        // fetch the JSON data from Flickr
        NSData *jsonResults = [NSData dataWithContentsOfURL:url];
        // convert it to a Property List (NSArray and NSDictionary)
        NSDictionary *propertyListResults = [NSJSONSerialization JSONObjectWithData:jsonResults
                                                                            options:0
                                                                              error:NULL];
        // get the NSArray of photo NSDictionarys out of the results
        NSArray *photos = [propertyListResults valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        // update the Model (and thus our UI), but do so back on the main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.refreshControl endRefreshing]; // stop the spinner
            self.photos = photos;
        });
    });
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Place Photos Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    NSDictionary *photo = self.photos[indexPath.row];
    cell.textLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    cell.detailTextLabel.text = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    return cell;
}

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
{
    ivc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    ivc.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    [Helpers addPhoto:photo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        // find out which row in which section we're seguing from
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            // found it ... are we doing the Display Photo segue?
            if ([segue.identifier isEqualToString:@"Display Photo"]) {
                // yes ... is the destination an ImageViewController?
                if ([segue.destinationViewController isKindOfClass:[ImageViewController class]]) {
                    // yes ... then we know how to prepare for that segue!
                    [self prepareImageViewController:segue.destinationViewController
                                      toDisplayPhoto:self.photos[indexPath.row]];
                }
            }
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the Detail view controller in our UISplitViewController (nil if not in one)
    id detail = self.splitViewController.viewControllers[1];
    // if Detail is a UINavigationController, look at its root view controller to find it
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row]];
    // is the Detail is an ImageViewController?
    /*if ([detail isKindOfClass:[ImageViewController class]]) {
        // yes ... we know how to update that!
        [self prepareImageViewController:detail toDisplayPhoto:self.photos[indexPath.row]];
    }*/
}

@end
