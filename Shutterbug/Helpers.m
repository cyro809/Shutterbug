//
//  Helpers.m
//  Shutterbug
//
//  Created by Cyro Guimaraes on 11/15/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "Helpers.h"
@interface Helpers()<NSURLSessionDownloadDelegate>
@property (strong, nonatomic) NSURLSession *downloadSession;
@property (copy, nonatomic) void (^recentPhotosCompletionHandler)(NSArray *photos, void(^whenDone)());
@property (copy, nonatomic) void (^downloadBackgroundURLSessionCompletionHandler)();


@end


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

#define FLICKR_FETCH_RECENT_PHOTOS @"Flickr Download Task to Download Recent Photos"

+ (void)startBackgroundDownloadRecentPhotosOnCompletion:(void (^)(NSArray *photos, void(^whenDone)()))completionHandler
{
    Helpers *fh = [Helpers sharedHelper];
    [fh.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if (![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [fh.downloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH_RECENT_PHOTOS;
            fh.recentPhotosCompletionHandler = completionHandler;
            [task resume];
        } else {
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
        }
    }];
}

#define FLICKR_FETCH @"Flickr Download Session"

- (NSURLSession *)downloadSession
{
    if (!_downloadSession) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _downloadSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration backgroundSessionConfiguration:FLICKR_FETCH]
                                                             delegate:self
                                                        delegateQueue:nil];
        });
    }
    return _downloadSession;
}

+ (void)handleEventsForBackgroundURLSession:(NSString *)identifier
                          completionHandler:(void (^)())completionHandler
{
    if ([identifier isEqualToString:FLICKR_FETCH]) {
        Helpers *fh = [Helpers sharedHelper];
        fh.downloadBackgroundURLSessionCompletionHandler = completionHandler;
    }
}

+ (Helpers *)sharedHelper
{
    static dispatch_once_t pred = 0;
    __strong static Helpers *_sharedHelper = nil;
    dispatch_once(&pred, ^{
        _sharedHelper = [[self alloc] init];
    });
    return _sharedHelper;
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
}


- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
    
}

- (void)downloadTasksMightBeComplete
{
    if (self.downloadBackgroundURLSessionCompletionHandler) {
        [self.downloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void (^completionHandler)() = self.downloadBackgroundURLSessionCompletionHandler;
                self.downloadBackgroundURLSessionCompletionHandler = nil;
                if (completionHandler) {
                    completionHandler();
                }
            }
        }];
    }
}

- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location
{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_FETCH_RECENT_PHOTOS]) {
        NSDictionary *flickrPropertyList;
        NSData *flickrJSONData = [NSData dataWithContentsOfURL:location];
        if (flickrJSONData) {
            flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                                 options:0
                                                                   error:NULL];
        }
        NSArray *photos = [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        
        self.recentPhotosCompletionHandler(photos, ^{
            [self downloadTasksMightBeComplete];
        });
    }
}

+ (void)loadRecentPhotosOnCompletion:(void (^)(NSArray *places, NSError *error))completionHandler
{
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    config.allowsCellularAccess = NO;
    config.timeoutIntervalForRequest = 10;
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDownloadTask *task = [session downloadTaskWithURL:[Helpers URLforRecentGeoreferencedPhotos]
                                                completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                    NSArray *photos;
                                                    if (!error) {
                                                        photos = [[NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:location]
                                                                                                  options:0
                                                                                                    error:&error] valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                                                    }
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        completionHandler(photos, error);
                                                    });
                                                }];
    [task resume];
}

@end
