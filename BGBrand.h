//
//  Brand.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/8/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BGCategory;
@class BGCompany;

@interface BGBrand :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSString * nameSortFormatted;
@property (nonatomic, retain) NSString * namefirstLetter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isCompanyName;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) NSSet* companies;

@property (nonatomic, retain) NSNumber * nonResponder;
@property (nonatomic, retain) NSNumber * ratingLevel;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSNumber * partner;
@property (nonatomic, retain) NSNumber * includeInIndex;

@end


@interface BGBrand (CoreDataGeneratedAccessors)
- (void)addCategoriesObject:(BGCategory *)value;
- (void)removeCategoriesObject:(BGCategory *)value;
- (void)addCategories:(NSSet *)value;
- (void)removeCategories:(NSSet *)value;

- (void)addCompaniesObject:(BGCompany *)value;
- (void)removeCompaniesObject:(BGCompany *)value;
- (void)addCompanies:(NSSet *)value;
- (void)removeCompanies:(NSSet *)value;

@end

