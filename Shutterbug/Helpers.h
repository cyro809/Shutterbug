//
//  Helpers.h
//  Shutterbug
//
//  Created by Cyro Guimaraes on 11/15/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "FlickrFetcher.h"

@interface Helpers : FlickrFetcher

+ (NSArray *)sortPlaces:(NSArray *)places;
+ (NSDictionary *)placesByCountries:(NSArray *)places;
+ (NSArray *)countriesFromPlacesByCountry:(NSDictionary *)placesByCountry;
+ (NSString *)titleOfPlace:(NSDictionary *)place;

@end
