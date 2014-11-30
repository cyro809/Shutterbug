//
//  Photographer+Create.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (Create)

+ (Photographer *)photographerWithName:(NSString *)name andRegionName:(NSString *)regionName
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
