//
//  Category.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/6/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Brand;
@class Company;

@interface Category :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * nameDisplayFriendly;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* brands;
@property (nonatomic, retain) NSSet* companies;

@end


@interface Category (CoreDataGeneratedAccessors)
- (void)addBrandsObject:(Brand *)value;
- (void)removeBrandsObject:(Brand *)value;
- (void)addBrands:(NSSet *)value;
- (void)removeBrands:(NSSet *)value;

- (void)addCompaniesObject:(Company *)value;
- (void)removeCompaniesObject:(Company *)value;
- (void)addCompanies:(NSSet *)value;
- (void)removeCompanies:(NSSet *)value;

@end

