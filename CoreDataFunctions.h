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


NSArray* allCompanies(NSManagedObjectContext* context);
NSArray* allCategories(NSManagedObjectContext* context);
NSArray* allBrands(NSManagedObjectContext* context);

Category* categoryWithName(NSString* name, NSManagedObjectContext* context);
Brand* brandWithName(NSString* name, NSManagedObjectContext* context);
Company* companyWithName(NSString* name, NSManagedObjectContext* context);
Company* companyWithID(NSNumber* ID, NSManagedObjectContext* context);

