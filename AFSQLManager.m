//
//  AFSQLManager.m
//  AFSQLManager
//
//  Created by Alvaro Franco on 4/17/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "AFSQLManager.h"

@interface AFSQLManager ()

@property (nonatomic, strong) NSString *dbPath;
@property (nonatomic, strong) NSString *docsPath;
@property (nonatomic, strong) NSDictionary *currentDbInfo;
@end

@implementation AFSQLManager

-(id)init {
    
    self = [super init];
    
    if (self) {
        _docsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    }
    
    return self;
}

+(instancetype)sharedManager {
    
    static AFSQLManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc]init];
    });
    
    return sharedManager;
}

-(void)createDatabaseWithName:(NSString *)name openInmediately:(BOOL)open withStatusBlock:(statusBlock)status {
    
    NSError *error = nil;
    _dbPath = [_docsPath stringByAppendingPathComponent:name];
    [[NSData data]writeToFile:_dbPath options:NSDataWritingAtomic error:&error];
    
    if (!error) {
        if (open) {
            [self openLocalDatabaseWithName:name andStatusBlock:^(BOOL success, NSError *error) {
                if (success) {
                    status(YES, nil);
                    _currentDbInfo = @{@"name": name};
                } else {
                    status(NO, nil);
                }
            }];
        }
    } else {
        status(NO, error);
    }
}

-(void)openLocalDatabaseWithName:(NSString *)name andStatusBlock:(statusBlock)status {
    
	if (sqlite3_open([[_docsPath stringByAppendingPathComponent:name] UTF8String], &_database) == SQLITE_OK) {
        status(YES, nil);
    } else {
        status(NO, nil);
    }
}

-(void)closeLocalDatabaseWithName:(NSString *)name andStatusBlock:(statusBlock)status {
    
    if (sqlite3_close(_database) == SQLITE_OK) {
        status(YES, nil);
    } else {
        status(NO, nil);
    }
}

-(void)renameDatabaseWithName:(NSString *)originalName toName:(NSString *)newName andStatus:(statusBlock)status {
    
    if ([[_currentDbInfo objectForKey:@"name"]isEqualToString:originalName]) {
        sqlite3_close(_database);
    }
    
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager moveItemAtPath:[_docsPath stringByAppendingPathComponent:originalName] toPath:[_docsPath stringByAppendingPathComponent:newName] error:&error];
    
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
    [fileManager removeItemAtPath:[_docsPath stringByAppendingPathComponent:name] error:&error];
    
    if (!error) {
        status(YES, nil);
        _currentDbInfo = @{@"name": [NSNull null]};
    } else {
        status(NO, error);
        [self openLocalDatabaseWithName:name andStatusBlock:nil];
    }
}

-(void)performQuery:(NSString *)query withBlock:(completionBlock)completion {
    
    if (_currentDbInfo[@"name"] != [NSNull null]) {
        
		sqlite3_stmt *compiledStatement;
        
		if (sqlite3_prepare_v2(_database, [query cStringUsingEncoding:NSASCIIStringEncoding], -1, &compiledStatement, NULL) == SQLITE_OK) {

			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
                
                NSMutableArray *row = [NSMutableArray array];
                
                for (int i = 0; i < sqlite3_column_count(compiledStatement); i++) {
                    
                    [row addObject:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, (i + 1))]];
                }
                
                completion(row, nil);
			}
		}
		sqlite3_finalize(compiledStatement);
	}
    
	sqlite3_close(_database);
}

@end
