//
//  ResentsTVC.m
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import "RecentsPhotosTVC.h"
#import "Photo.h"
#import "DBHelper.h"
#import "ImageViewController.h"

@interface RecentsPhotosTVC ()

@end

@implementation RecentsPhotosTVC

- (void)setupFetchedResultsControllerWithDocument:(UIManagedDocument *)document
    
    {
        NSFetchRequest *request       =  [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors       =  [NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"dateStamp" ascending:NO]];
        request.predicate             =  [NSPredicate predicateWithFormat:@"dateStamp!=nil"];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc]
                                         initWithFetchRequest:request
                                         managedObjectContext:document.managedObjectContext
                                         sectionNameKeyPath:nil cacheName:nil];
    }
    
    -(void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
        [[DBHelper sharedManagedDocument] performWithDocument:^(UIManagedDocument *document) {
            [self setupFetchedResultsControllerWithDocument:document];
        }];
    }
    
    -(void)viewDidAppear:(BOOL)animated
    {
        [super viewDidAppear:animated];
        
        if (self.fetchedResultsController.fetchedObjects !=nil) {
            self.title =[NSString stringWithFormat:@"Photos (%lu)",(unsigned long)[self.fetchedResultsController.fetchedObjects count]];
        } else {
            self.title =[NSString stringWithFormat:@"Photos (-)"];
        }
    }

@end
