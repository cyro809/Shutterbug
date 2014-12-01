//
//  ImageCache.m
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "DataCache.h"

@interface DataCache()

  @property (nonatomic, readwrite) NSUInteger cacheSize;

  @property (strong, nonatomic) NSFileManager *fileManager;
  @property (nonatomic, getter = isRunningOniPad) BOOL runningOniPad;

@end


@implementation DataCache


#define MAX_CACHE_SIZE			3	*1048576	// [ MB ]
#define MAX_CACHE_IPAD_FACTOR	4


# pragma mark   -   cache methods

- (BOOL)cacheData:(NSData *)data withIdentifier:(NSString *)identifier
{
	NSArray *directoryContents = [self.fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:self.cacheDirectory]
												 includingPropertiesForKeys:@[NSURLContentAccessDateKey]
																	options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
	
	NSMutableArray *contentFilesSortedByLastAccessDateNewerToOlderArray = [[directoryContents sortedArrayUsingComparator: ^(NSURL* url1, NSURL* url2) {
		NSDate *date1 = [url1 resourceValuesForKeys:@[NSURLContentAccessDateKey] error:nil][NSURLContentAccessDateKey];
		NSDate *date2 = [url2 resourceValuesForKeys:@[NSURLContentAccessDateKey] error:nil][NSURLContentAccessDateKey];
		
		return [date2 compare: date1];
		
	}] mutableCopy];
	
	while (self.cacheSize >= self.maxCacheSize && directoryContents.count > 0) {
		NSLog(@"cachSize: %lu , maxCacheSize: %lu , directoryContents.count: %lu ",(unsigned long)self.cacheSize,(unsigned long) self.maxCacheSize, (unsigned long)directoryContents.count);
        
		NSError *hardimitzn = nil;
		if (![self.fileManager removeItemAtURL:[contentFilesSortedByLastAccessDateNewerToOlderArray lastObject] error:&hardimitzn]) NSLog(@"%@", [hardimitzn localizedDescription]);
		else [contentFilesSortedByLastAccessDateNewerToOlderArray removeLastObject];
	}
	
	NSString * targetFilePath = [self.cacheDirectory stringByAppendingPathComponent:identifier];
	
	return [data writeToFile:targetFilePath atomically:YES];
}


- (NSData *)dataInCacheForIdentifier:(NSString *)identifier
{
	NSString * targetFilePath = [self.cacheDirectory stringByAppendingPathComponent:identifier];
	NSData *data;
	if ([self.fileManager fileExistsAtPath:targetFilePath]) {
		data = [[NSData alloc] initWithContentsOfFile:targetFilePath];
	}
	return data;
}


//----------------------------------------------------------------
# pragma mark   -   Accessors
//----------------------------------------------------------------


+ (id)sharedInstance
{
	__strong static id _sharedObject = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		_sharedObject = [[self alloc] init];
	});
	
	return _sharedObject;
}


- (NSString *)cacheDirectory
{
	if (!_cacheDirectory) {
       
        NSURL *cachesDir = [self.fileManager URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        NSURL *imagesDir = [cachesDir URLByAppendingPathComponent:@"Images"];
        if (![self.fileManager fileExistsAtPath:[imagesDir path]]) {
            [self.fileManager createDirectoryAtURL:imagesDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        _cacheDirectory=[imagesDir path];
    }
	return _cacheDirectory;
}
- (NSUInteger)maxCacheSize
{
	if (!_maxCacheSize) _maxCacheSize = self.isRunningOniPad ? MAX_CACHE_SIZE * MAX_CACHE_IPAD_FACTOR : MAX_CACHE_SIZE;
	return _maxCacheSize;
}

- (NSUInteger)cacheSize{
	
	NSUInteger fileSize = floor(M_1_PI*10000000);
	
	if (self.cacheDirectory != nil) {
		fileSize = 0;
		NSArray *filesArray = [self.fileManager contentsOfDirectoryAtPath:self.cacheDirectory error:nil];
		NSString *fileName;
		
		for (fileName in filesArray) {
			NSDictionary *fileDictionary = [self.fileManager attributesOfItemAtPath:[self.cacheDirectory stringByAppendingPathComponent:fileName] error:nil];
			fileSize += [fileDictionary fileSize];
		}
	}
		NSLog(@"cacheSize: %lu", (unsigned long)fileSize);
    return fileSize;
}

- (NSFileManager *)fileManager
{
	if (!_fileManager) _fileManager = [[NSFileManager alloc] init];
	return _fileManager;
}
- (BOOL)isRunningOniPad
{
	if (!_runningOniPad) _runningOniPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
	return _runningOniPad;
}


@end