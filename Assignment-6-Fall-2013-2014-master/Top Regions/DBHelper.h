//
//  DBHelper.h
//  Top Regions
//
//  Created by Cyro Guimaraes on 11/29/14.
//  Copyright (c) 2014 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^OnDocumentReady) (UIManagedDocument *document);

@interface DBHelper : NSObject


@property (nonatomic, strong) NSString *dbName;
@property (nonatomic, strong) UIManagedDocument *database;
@property (nonatomic, strong) NSFileManager *fileManager;

+ (DBHelper *)sharedManagedDocument;
- (void)openDBUsingBlock:(void (^)(BOOL success))block;
- (void)performWithDocument:(OnDocumentReady)onDocumentReady;

@end
