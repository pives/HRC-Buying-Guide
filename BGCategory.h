//
//  Category.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/6/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BGBrand;
@class BGCompany;

@interface BGCategory :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * nameDisplayFriendly;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* brands;
@property (nonatomic, retain) NSSet* companies;

@end


@interface BGCategory (CoreDataGeneratedAccessors)
- (void)addBrandsObject:(BGBrand *)value;
- (void)removeBrandsObject:(BGBrand *)value;
- (void)addBrands:(NSSet *)value;
- (void)removeBrands:(NSSet *)value;

- (void)addCompaniesObject:(BGCompany *)value;
- (void)removeCompaniesObject:(BGCompany *)value;
- (void)addCompanies:(NSSet *)value;
- (void)removeCompanies:(NSSet *)value;

@end

