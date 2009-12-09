//
//  Brand.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/8/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Category;
@class Company;

@interface Brand :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * partner;
@property (nonatomic, retain) NSString * nameSortFormatted;
@property (nonatomic, retain) NSNumber * ratingLevel;
@property (nonatomic, retain) NSString * namefirstLetter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isCompanyName;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) NSSet* companies;

@end


@interface Brand (CoreDataGeneratedAccessors)
- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)value;
- (void)removeCategories:(NSSet *)value;

- (void)addCompaniesObject:(Company *)value;
- (void)removeCompaniesObject:(Company *)value;
- (void)addCompanies:(NSSet *)value;
- (void)removeCompanies:(NSSet *)value;

@end

