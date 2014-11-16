//
//  Helpers.m
//  Shutterbug
//
//  Created by Cyro Guimaraes on 11/15/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Helpers.h"

@implementation Helpers


+ (NSArray *)sortPlaces:(NSArray *)places
{
    return [places sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *name1 = [obj1 valueForKeyPath:FLICKR_PLACE_NAME];
        NSString *name2 = [obj2 valueForKeyPath:FLICKR_PLACE_NAME];
        return [name1 localizedCompare:name2];
    }];
}

+ (NSDictionary *)placesByCountries:(NSArray *)places
{
    NSMutableDictionary *placesByCountry = [NSMutableDictionary dictionary];
    for (NSDictionary *place in places) {
        NSString *country = [Helpers countryOfPlace:place];
        NSMutableArray *placesOfCountry = placesByCountry[country];
        if (!placesOfCountry) {
            placesOfCountry = [NSMutableArray array];
            placesByCountry[country] = placesOfCountry;
        }
        [placesOfCountry addObject:place];
    }
    return placesByCountry;
}

+ (NSArray *)countriesFromPlacesByCountry:(NSDictionary *)placesByCountry
{
    NSArray *countries = [placesByCountry allKeys];
    countries = [countries sortedArrayUsingComparator:^(id a, id b) {
        return [a compare:b options:NSCaseInsensitiveSearch];
    }];
    return countries;
}

+ (NSString *)titleOfPlace:(NSDictionary *)place
{
    return [[[place valueForKeyPath:FLICKR_PLACE_NAME]
             componentsSeparatedByString:@", "] firstObject];
}

+ (NSString *)subtitleOfPlace:(NSDictionary *)place
{
    NSArray *nameParts = [[place valueForKeyPath:FLICKR_PLACE_NAME]
                          componentsSeparatedByString:@", "];
    return [NSString stringWithFormat:@"%@, %@", [nameParts objectAtIndex:1], [nameParts objectAtIndex:2]];
}

+ (NSString *)countryOfPlace:(NSDictionary *)place
{
    return [[[place valueForKeyPath:FLICKR_PLACE_NAME]
             componentsSeparatedByString:@", "] lastObject];
}

+ (NSString *)IDforPhoto:(NSDictionary *)photo
{
    return [photo valueForKeyPath:FLICKR_PHOTO_ID];
}

#define RECENT_PHOTOS_KEY @"Recent_Photos_Key"
+ (NSArray *)allPhotos
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:RECENT_PHOTOS_KEY];
}

#define RECENT_PHOTOS_MAX_NUMBER 20
+ (void)addPhoto:(NSDictionary *)photo
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *photos = [[defaults objectForKey:RECENT_PHOTOS_KEY] mutableCopy];
    if (!photos) photos = [NSMutableArray array];
    NSUInteger key = [photos indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[Helpers IDforPhoto:photo] isEqualToString:[Helpers IDforPhoto:obj]];
    }];
    if (key != NSNotFound) [photos removeObjectAtIndex:key];
    [photos insertObject:photo atIndex:0];
    while ([photos count] > RECENT_PHOTOS_MAX_NUMBER) {
        [photos removeLastObject];
    }
    [defaults setObject:photos forKey:RECENT_PHOTOS_KEY];
    [defaults synchronize];
}

@end
