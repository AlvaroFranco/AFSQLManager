AFSQLManager
==============

[![Build Status](https://travis-ci.org/AlvaroFranco/AFSQLManager.svg?branch=v1.0)](https://travis-ci.org/AlvaroFranco/AFSQLManager)
[![alt text](https://cocoapod-badges.herokuapp.com/v/AFSQLManager/badge.png "")]()
[![alt text](https://cocoapod-badges.herokuapp.com/p/AFSQLManager/badge.png "")]()
[![alt text](https://camo.githubusercontent.com/f513623dcee61532125032bbf1ddffda06ba17c7/68747470733a2f2f676f2d736869656c64732e6865726f6b756170702e636f6d2f6c6963656e73652d4d49542d626c75652e706e67 "")]()

SQL and SQLite database manage on iOS made easy. Create, open, rename and delete databases with AFSQLManager, a block-driven iOS SQL and SQLite manager class. Perform queries never has been that easy!

![alt text](https://raw.github.com/AlvaroFranco/AFSQLManager/master/preview.gif "Preview")

##Installation

AFSQLManager is available on CocoaPods so you can get it by adding this line to your Podfile:
	
	pod 'AFSQLManager', '~> 1.0'
	
If you don't use CocoaPods, you will have to import these files into your project:

	AFSQLManager.h
	AFSQLManager.m
	
Also, make sure to import ```libsqlite3.dylib``` library on the Frameworks section!

##Usage

First of all, make sure that you have imported the main class into the class where you are going to play audio.

	#import "AFSQLManager.h"
	
###Managing the databases files

#####Create a brand new database

To create a new file, use the method ```-createDatabaseWithName:openImmediately:withStatusBlock:```. Let's say you need to create a database called nyancat.sqlite:

    [[AFSQLManager sharedManager]createDatabaseWithName:@"nyancat.sqlite" openInmediately:YES withStatusBlock:^(BOOL success, NSError *error) {
        
        if (success) {
        	// Yeah, database created successfully
        } else {
        	NSLog(@"%@",error);
        }
    }];

You can also choose if the database should be opened once it's created.
    
#####Open and closing an existing database

If you already have your database imported into your project, start using that database is as simple as use ```-openLocalDatabaseWithName:andStatusBlock:```

	[[AFSQLManager sharedManager]openLocalDatabaseWithName:@"my-awesome-db.sql" andStatusBlock:^(BOOL success, NSError *error) {
        
        // Handle the error to check it has been opened properly
    }];
    
To close it, call ```-closeLocalDatabaseWithName:andStatusBlock:```

#####Renaming and deleting

To rename and delete your database, we have these two methods:

	-renameDatabaseWithName:toName:andStatus:
	-deleteDatabaseWithName:andStatus:
		
###Performing queries

Queries are performed with the method ```-performQuery:withBlock:```, which is also block-based.

For example, if you want to look for all the items inside a table (which query is ```SELECT * FROM tableName```), the code would be:
	
	[[AFSQLManager sharedManager]performQuery:@"SELECT * FROM tableName" withBlock:^(NSArray *row, NSError *error, BOOL finished) {
        
        // Handle each row
    }];
    
The block will be executed on every row, and it will contain an array (```row```) with each column in that row.

##License
AFSQLManager is under MIT license so feel free to use it!

##Author
Made by Alvaro Franco. If you have any question, feel free to drop me a line at [alvarofrancoayala@gmail.com](mailto:alvarofrancoayala@gmail.com)
