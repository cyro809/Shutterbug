//
//  ImagesPlacesViewController.h
//  Shutterbug
//
//  Created by Cyro Guimaraes on 11/15/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "JustPostedFlickrPhotosTVC.h"

@interface ImagesPlacesViewController : UITableViewController

@property (nonatomic, strong) NSDictionary *place;
@property (nonatomic, strong) NSArray *photos;

@end
