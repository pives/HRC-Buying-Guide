//
//  CoreDataFunctions.h
//  BGImporter
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

@class Company;
@class Category;
@class Brand;


NSError* save(NSManagedObjectContext* context);

NSArray* allCompanies(NSManagedObjectContext* context);
Category* categoryWithName(NSString* name, NSManagedObjectContext* context);
Brand* brandWithName(NSString* name, NSManagedObjectContext* context);
NSSet* brandsWithString(NSString* string, NSManagedObjectContext* context);
Company* companyWithName(NSString* name, NSManagedObjectContext* context);
Company* companyWithID(NSNumber* ID, NSManagedObjectContext* context);



//TODO: refactor to use core data accessors for adding/deleting/setting properties (also in importer app)