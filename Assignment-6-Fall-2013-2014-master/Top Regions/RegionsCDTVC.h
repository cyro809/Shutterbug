//
//  RegionsCDTVC.h
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "CoreDataTableViewController.h"

@interface RegionsCDTVC : CoreDataTableViewController
@property (nonatomic,strong)NSManagedObjectContext *managedObjectContext;
@end
