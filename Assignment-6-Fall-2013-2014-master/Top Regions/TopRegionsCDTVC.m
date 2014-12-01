//
//  TopRegionsCDTVC.m
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "TopRegionsCDTVC.h"
#import "FlickrFetcher.h"
#import "DBHelper.h"
#import "Photo+Flickr.h"
#import "NetworkIndicatorHelper.h"

@interface TopRegionsCDTVC ()

@end

@implementation TopRegionsCDTVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleUpdatedData:)
                                                 name:@"DataUpdated"
                                               object:nil];
}

-(void)handleUpdatedData:(NSNotification *)notification {
    if(self.refreshControl.isRefreshing)  [self.refreshControl endRefreshing]; // stop the spinner
    NSLog(@"Data updated");
}


- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    if (flickrJSONData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                             options:0
                                                               error:NULL];
    }
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
}

- (void)useRegionDocumentWithFlickrPhotos:(NSArray *)photos
{
    [[DBHelper sharedManagedDocument] performWithDocument:^(UIManagedDocument *document) {
        self.managedObjectContext = document.managedObjectContext;
        
        [Photo load1PhotosFromFlickrArray:photos intoManagedObjectContext:self.managedObjectContext];
        [document saveToURL:document.fileURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:NULL];
    }];
}

- (void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile
{
    NSArray *photos = [self flickrPhotosAtURL:localFile];
    [self useRegionDocumentWithFlickrPhotos:photos];
}


@end
