//
//  FlickrPhotosTVC.h
//  Shutterbug
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlickrRegionsTVC : UITableViewController

// Model of this MVC (it can be publicly set)
@property (nonatomic, strong) NSArray *places;
@property (nonatomic, strong) NSArray *photos;
@end
