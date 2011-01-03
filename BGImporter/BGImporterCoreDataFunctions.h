//
//  BGImporterCoreDataFunctions.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/20/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class BGCompany;
@class BGCategory;
@class BGBrand;


NSError* save(NSManagedObjectContext* context);

NSError* importUsingCSV(NSManagedObjectContext* context);
BGCompany* processRowIntoContext(NSArray *row, NSManagedObjectContext* context);
void addPartnerSpecialCases(NSManagedObjectContext* context);

BGCompany* companyWithRow(NSArray* row, NSManagedObjectContext* context);
BGCompany* companyByaddingCategoryToCompany(BGCategory* aCategory, BGCompany* aCompany);
BGCompany* companyByaddingBrandsToCompany(NSSet* someBrands, BGCompany* aCompany);
NSMutableSet* brandsWithString(NSString* string, NSManagedObjectContext* context);
void associateBrandsWithCategory(NSSet* someBrands, BGCategory* aCategory);
NSNumber* ratingLevelForScore(int rating);
NSString* indexCharForName(NSString* aString);