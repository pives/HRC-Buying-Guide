//
//  CoreDataFunctions.h
//  BGImporter
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

@class BGCompany;
@class BGCategory;
@class BGBrand;


NSArray* allCompanies(NSManagedObjectContext* context);
NSArray* allCategories(NSManagedObjectContext* context);
NSArray* allBrands(NSManagedObjectContext* context);

BGCategory* categoryWithName(NSString* name, NSManagedObjectContext* context);
BGBrand* brandWithName(NSString* name, NSManagedObjectContext* context);
BGCompany* companyWithName(NSString* name, NSManagedObjectContext* context);
BGCompany* companyWithID(NSNumber* ID, NSManagedObjectContext* context);

