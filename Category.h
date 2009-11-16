//
//  Category.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/15/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Brand;
@class Company;

@interface Category :  NSManagedObject  
{
}

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet* companies;
@property (nonatomic, retain) NSSet* brands;

@end


@interface Category (CoreDataGeneratedAccessors)
- (void)addCompaniesObject:(Company *)value;
- (void)removeCompaniesObject:(Company *)value;
- (void)addCompanies:(NSSet *)value;
- (void)removeCompanies:(NSSet *)value;

- (void)addBrandsObject:(Brand *)value;
- (void)removeBrandsObject:(Brand *)value;
- (void)addBrands:(NSSet *)value;
- (void)removeBrands:(NSSet *)value;

@end

