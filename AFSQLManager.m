//
//  AFSQLManager.m
//  AFSQLManager
//
//  Created by Alvaro Franco on 4/17/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "AFSQLManager.h"

@interface AFSQLManager ()

@property (nonatomic, strong) NSDictionary *currentDbInfo;
@end

@implementation AFSQLManager

+(instancetype)sharedManager {
    
    static AFSQLManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
    });
    
    return sharedManager;
}

-(void)createDatabaseWithName:(NSString *)name openImmediately:(BOOL)openImmediately withStatusBlock:(statusBlock)status {
    
    NSError *error = nil;
    [[NSData data]writeToFile:[[NSBundle mainBundle]pathForResource:[[name lastPathComponent]stringByDeletingPathExtension] ofType:[name pathExtension]] options:NSDataWritingAtomic error:&error];
    
    if (!error) {
        if (openImmediately) {
            [self openLocalDatabaseWithName:name andStatusBlock:^(BOOL success, NSError *error) {
                if (success) {
                    _currentDbInfo = @{@"name": name};
                }
    
                status(success, error);
            }];
        } else {
            status(YES, nil);
        }
    } else {
        status(NO, error);
    }
}

-(void)openLocalDatabaseWithName:(NSString *)name andStatusBlock:(statusBlock)status {
    
    NSString *path = [[NSBundle mainBundle]pathForResource:[[name lastPathComponent]stringByDeletingPathExtension] ofType:[name pathExtension]];

    if (sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
        NSLog(@"Failed to open database!");
        status(NO, nil);
    } else {
        NSLog(@"Database opened properly");
        status(YES, nil);
    }
}

-(void)closeLocalDatabaseWithName:(NSString *)name andStatusBlock:(statusBlock)status {
    
    if (sqlite3_close(_database) == SQLITE_OK) {
        status(YES, nil);
    } else {
        
    }
}

-(void)renameDatabaseWithName:(NSString *)originalName toName:(NSString *)newName andStatus:(statusBlock)status {
    
    if ([[_currentDbInfo objectForKey:@"name"]isEqualToString:originalName]) {
        sqlite3_close(_database);
    }
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager moveItemAtPath:[[NSBundle mainBundle]pathForResource:[[originalName lastPathComponent]stringByDeletingPathExtension] ofType:[originalName pathExtension]] toPath:[[NSBundle mainBundle]pathForResource:[[newName lastPathComponent]stringByDeletingPathExtension] ofType:[newName pathExtension]] error:&error];
    
    if ([[_currentDbInfo objectForKey:@"name"]isEqualToString:originalName] && !error) {
        [self openLocalDatabaseWithName:newName andStatusBlock:nil];
        _currentDbInfo = @{@"name": newName};
        status(YES, nil);
    } else if ([[_currentDbInfo objectForKey:@"name"]isEqualToString:originalName] && error) {
        [self openLocalDatabaseWithName:originalName andStatusBlock:nil];
        status(YES, error);
    }
}

-(void)deleteDatabaseWithName:(NSString *)name andStatus:(statusBlock)status {
    
    if ([[_currentDbInfo objectForKey:@"name"]isEqualToString:name]) {
        sqlite3_close(_database);
    }
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[[NSBundle mainBundle]pathForResource:[[name lastPathComponent]stringByDeletingPathExtension] ofType:[name pathExtension]] error:&error];
    
    if (!error) {
        status(YES, nil);
        _currentDbInfo = @{@"name": [NSNull null]};
    } else {
        status(NO, error);
        [self openLocalDatabaseWithName:name andStatusBlock:nil];
    }
}

-(void)performQuery:(NSString *)query withBlock:(completionBlock)completion {
    
    NSString *fixedQuery = [query stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    sqlite3_stmt *statement;
    
    if (sqlite3_prepare_v2(_database, [fixedQuery UTF8String], -1, &statement, nil) == SQLITE_OK) {
        
        while (sqlite3_step(statement) == SQLITE_ROW) {
            
            NSMutableArray *row = [NSMutableArray array];
            
            for (int i = 0; i < sqlite3_column_count(statement); i++) {
                
                [row addObject:((char *)sqlite3_column_text(statement, i)) ? [NSString stringWithUTF8String:(char *)sqlite3_column_text(statement, i)] : [NSNull null]];
            }
            
            if (completion) {
                completion(row, nil, NO);
            }
        }
        
        sqlite3_finalize(statement);
        completion(nil, nil, YES);
    }
}

@end
