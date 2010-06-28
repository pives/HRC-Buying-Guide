//
//  Company.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/19/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BGBrand;
@class BGCategory;

@interface BGCompany :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * ID;
@property (nonatomic, retain) NSNumber * partner;
@property (nonatomic, retain) NSNumber * ratingLevel;
@property (nonatomic, retain) NSString * namefirstLetter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * officialName;
@property (nonatomic, retain) NSSet* brands;
@property (nonatomic, retain) NSSet* categories;

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

