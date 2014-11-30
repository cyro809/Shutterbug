//
//  MyUIManagedDocument.m
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "MyUIManagedDocument.h"

@implementation MyUIManagedDocument
+(NSString*) persistentStoreName{
    return @"RegionData.sqlite";
}
  
@end
