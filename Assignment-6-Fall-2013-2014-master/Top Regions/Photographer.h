//
//  Photographer.h
//  Photomania
//
//  Created by CS193p Instructor.
//  Copyright (c) 2013 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Region;

@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photosByPhotographer;
@property (nonatomic, retain) Region *region;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPhotosByPhotographerObject:(Photo *)value;
- (void)removePhotosByPhotographerObject:(Photo *)value;
- (void)addPhotosByPhotographer:(NSSet *)values;
- (void)removePhotosByPhotographer:(NSSet *)values;

@end
