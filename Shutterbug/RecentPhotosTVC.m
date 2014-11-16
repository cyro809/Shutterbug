//
//  RecentPhotosTVC.m
//  Shutterbug
//
//  Created by Cyro Guimaraes on 11/16/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "RecentPhotosTVC.h"
#import "Helpers.h"

@interface RecentPhotosTVC ()

@end

@implementation RecentPhotosTVC


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
	self.photos = [Helpers allPhotos];
}

@end
