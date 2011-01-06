//
//  Company.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/19/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#define GOOD_COMPANY_RATING 0
#define OK_COMPANY_RATING 1
#define BAD_COMPANY_RATING 2


#import <CoreData/CoreData.h>

@class BGBrand;
@class BGCategory;

@interface BGCompany :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * partner;
@property (nonatomic, retain) NSNumber * ratingLevel;
@property (nonatomic, retain) NSNumber * includeInIndex;
@property (nonatomic, retain) NSString * namefirstLetter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* brands;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) NSNumber* nonResponder;

- (void)syncCategories;

@end


@interface BGCompany (CoreDataGeneratedAccessors)
- (void)addBrandsObject:(BGBrand *)value;
- (void)removeBrandsObject:(BGBrand *)value;
- (void)addBrands:(NSSet *)value;
- (void)removeBrands:(NSSet *)value;

- (void)addCategoriesObject:(BGCategory *)value;
- (void)removeCategoriesObject:(BGCategory *)value;
- (void)addCategories:(NSSet *)value;
- (void)removeCategories:(NSSet *)value;

@end

