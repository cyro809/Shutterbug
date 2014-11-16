//
//  FlickrPhotosTVC.m
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "FlickrRegionsTVC.h"
#import "FlickrFetcher.h"
#import "ImageViewController.h"
#import "ImagesRegionsViewController.h"
#import "Helpers.h"

@interface FlickrRegionsTVC()

@property (nonatomic, strong) NSDictionary *placesByCountry;
@property (nonatomic, strong) NSArray *countries;

@end

@implementation FlickrRegionsTVC

// whenever our Model is set, must update our View

- (void)setPlaces:(NSArray *)places
{
    _places = [Helpers sortPlaces:places];
    if (_places == places) return;
    
    _places = [Helpers sortPlaces:places];
    
    self.placesByCountry = [Helpers placesByCountries:_places];
    self.countries = [Helpers countriesFromPlacesByCountry:self.placesByCountry];
    
    [self.tableView reloadData];
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource

// the methods in this protocol are what provides the View its data
// (remember that Views are not allowed to own their data)

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.countries count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section (we only have one)
    return [self.placesByCountry[self.countries[section]] count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return self.countries[section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we must be sure to use the same identifier here as in the storyboard!
    static NSString *CellIdentifier = @"Flickr Photo Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier
                                                            forIndexPath:indexPath];
    
    NSDictionary *place = self.placesByCountry[self.countries[indexPath.section]][indexPath.row];
    
    
    NSArray *placesInfo = [[place valueForKeyPath:FLICKR_PLACE_NAME] componentsSeparatedByString:@", "];
    NSString *title = [placesInfo objectAtIndex:0];
    NSString *subtitle = [NSString stringWithFormat:@"%@, %@", [placesInfo objectAtIndex:1], [placesInfo objectAtIndex:2]];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

#pragma mark - UITableViewDelegate

// when a row is selected and we are in a UISplitViewController,
//   this updates the Detail ImageViewController (instead of segueing to it)
// knows how to find an ImageViewController inside a UINavigationController in the Detail too
// otherwise, this does nothing (because detail will be nil and not "isKindOfClass:" anything)

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // get the Detail view controller in our UISplitViewController (nil if not in one)
    id detail = self.splitViewController.viewControllers[1];
    // if Detail is a UINavigationController, look at its root view controller to find it
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    // is the Detail is an ImageViewController?
    if ([detail isKindOfClass:[ImageViewController class]]) {
        // yes ... we know how to update that!
        [self prepareImageViewController:detail toDisplayPhoto:self.places[indexPath.row]];
    }
}

#pragma mark - Navigation

// prepares the given ImageViewController to show the given photo
// used either when segueing to an ImageViewController
//   or when our UISplitViewController's Detail view controller is an ImageViewController

- (void)prepareImageViewController:(ImageViewController *)ivc toDisplayPhoto:(NSDictionary *)photo
{
    ivc.imageURL = [FlickrFetcher URLforPhotosInPlace:[photo valueForKeyPath:FLICKR_PLACE_ID] maxResults:50];
    ivc.title = [photo valueForKeyPath:[FlickrFetcher extractNameOfPlace:[photo valueForKeyPath:FLICKR_PLACE_ID] fromPlaceInformation:photo]];
}

- (void)prepareRegionPhotosTableViewController:(ImagesRegionsViewController *)tvc forRegion:(NSDictionary *)region
{
    tvc.region = region;
    tvc.title = [Helpers titleOfPlace:region];
}

// In a story board-based application, you will often want to do a little preparation before navigation

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
                                      toDisplayPhoto:self.places[indexPath.row]];
                }
            }
            if ([segue.identifier isEqualToString:@"Show Place Photos"] && indexPath) {
                [self prepareRegionPhotosTableViewController:segue.destinationViewController
                              forRegion:self.placesByCountry[self.countries[indexPath.section]][indexPath.row]];
            }
        }
    }
}

@end
