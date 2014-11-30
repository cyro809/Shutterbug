//
//  Region+Create.h
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Region.h"

@interface Region (Create)
+ (Region *)regionWithName:(NSString *)name
                inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Region *)regionForPhotosWithName:(NSString *)name
    inManagedObjectContext:(NSManagedObjectContext *)context;

@end
