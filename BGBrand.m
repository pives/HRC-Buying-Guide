// 
//  Brand.m
//  BuyingGuide
//
//  Created by Corey Floyd on 12/8/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "BGBrand.h"
#import "BGCategory.h"
#import "BGCompany.h"


@interface BGBrand (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveCompanies;
- (void)setPrimitiveCompanies:(NSMutableSet*)value;

@end

@implementation BGBrand 

@dynamic includeInIndex;
@dynamic ID;
@dynamic rating;
@dynamic partner;
@dynamic nameSortFormatted;
@dynamic ratingLevel;
@dynamic namefirstLetter;
@dynamic name;
@dynamic isCompanyName;
@dynamic categories;
@dynamic companies;
@dynamic nonResponder;

- (void)updateAttributesInheritedFromCompanies {
	BGCompany *company = [self.companies anyObject];
	if ( company ) {
		[company addCategories:self.categories];
		[self addCategories:company.categories];
		self.rating = company.rating;
		self.ratingLevel = company.ratingLevel;
		self.partner = company.partner;
		self.nonResponder = company.nonResponder;
		self.includeInIndex = company.includeInIndex;
		
		if ( [self.name isEqualToString:company.name] )
			self.isCompanyName = [NSNumber numberWithBool:YES];
	}
	
	NSSet *safeCopy = [self.companies copy];
	for ( company in safeCopy ) {
		[company addBrandsObject:self];
	}
	[safeCopy release];
}


- (void)addCompaniesObject:(BGCompany *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"companies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveCompanies] addObject:value];
    [self didChangeValueForKey:@"companies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	[self updateAttributesInheritedFromCompanies];
}

- (void)removeCompaniesObject:(BGCompany *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"companies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveCompanies] removeObject:value];
    [self didChangeValueForKey:@"companies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	[self updateAttributesInheritedFromCompanies];
}

- (void)addCompanies:(NSSet *)value 
{    
    [self willChangeValueForKey:@"companies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveCompanies] unionSet:value];
    [self didChangeValueForKey:@"companies" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
	[self updateAttributesInheritedFromCompanies];
}

- (void)removeCompanies:(NSSet *)value 
{
    [self willChangeValueForKey:@"companies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveCompanies] minusSet:value];
    [self didChangeValueForKey:@"companies" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
	[self updateAttributesInheritedFromCompanies];
}




@end
