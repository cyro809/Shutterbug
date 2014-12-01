//
//  ImageCache.h
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataCache : NSObject

  @property (nonatomic) NSUInteger maxCacheSize;
  @property (nonatomic) NSString *cacheDirectory;
  @property (nonatomic, readonly) NSUInteger cacheSize;

+ (DataCache *)sharedInstance;

- (BOOL)cacheData:(NSData *)data withIdentifier:(NSString *)identifier;

- (NSData *)dataInCacheForIdentifier:(NSString *)identifier;



@end
