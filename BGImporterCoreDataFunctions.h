//
//  BGImporterCoreDataFunctions.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/20/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Company;
@class Category;
@class Brand;


NSError* save(NSManagedObjectContext* context);

NSError* importUsingCSV(NSManagedObjectContext* context);
Company* processRowIntoContext(NSArray *row, NSManagedObjectContext* context);

Company* companyWithRow(NSArray* row, NSManagedObjectContext* context);
Company* companyByaddingCategoryToCompany(Category* aCategory, Company* aCompany);
Company* companyByaddingBrandsToCompany(NSSet* someBrands, Company* aCompany);
NSSet* brandsWithString(NSString* string, NSManagedObjectContext* context);
void associateBrandsWithCategory(NSSet* someBrands, Category* aCategory);
NSNumber* ratingLevelForScore(int rating);
NSString* indexCharForName(NSString* aString);