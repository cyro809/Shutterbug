//
//  NetworkIndicatorHelper.h
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkIndicatorHelper : NSObject

+ (void) setNetworkActivityIndicatorVisible:(BOOL) visible;
+ (BOOL) networkActivityIndicatorVisible;

@end
