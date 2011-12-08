//
//  BGCompany.h
//  BuyingGuide
//
//  Created by Jake O'Brien on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#define GOOD_COMPANY_RATING 0
#define OK_COMPANY_RATING 1
#define BAD_COMPANY_RATING 2


#import <CoreData/CoreData.h>

@class BGBrand, BGCategory, BGScorecard;

@interface BGCompany : NSManagedObject

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * partner;
@property (nonatomic, retain) NSNumber * ratingLevel;
@property (nonatomic, retain) NSNumber * nonResponder;
@property (nonatomic, retain) NSNumber * includeInIndex;
@property (nonatomic, retain) NSString * namefirstLetter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *brands;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *scorecards;

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

- (void)addScorecardsObject:(BGScorecard *)values;
- (void)removeScorecardsObject:(BGScorecard *)values;
- (void)addScorecards:(NSSet *)values;
- (void)removeScorecards:(NSSet *)values;

@end
