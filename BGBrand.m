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
#import "NSString+extensions.h"

@interface BGBrand (CoreDataGeneratedPrimitiveAccessors)

- (NSString *)primitiveName;
- (void)setPrimitiveName:(NSString *)value;

- (NSMutableSet*)primitiveCompanies;
- (void)setPrimitiveCompanies:(NSMutableSet*)value;

- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;

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

- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:value];
    [self didChangeValueForKey:@"name"];
	
	
	self.nameSortFormatted = [value stringByRemovingArticlePrefixes];
	self.namefirstLetter = [self.nameSortFormatted uppercaseFirstCharacter];
}

- (void)updateAttributesInheritedFromCompanies {
	BGCompany *company = [self.companies anyObject];
	if ( company ) {
		[company addCategories:self.categories];
		self.rating = company.rating;
		self.ratingLevel = company.ratingLevel;
		self.partner = company.partner;
		self.nonResponder = company.nonResponder;
		self.includeInIndex = company.includeInIndex;
		
		if ( [self.name isEqualToString:company.name] )
			self.isCompanyName = [NSNumber numberWithBool:YES];
		
		if ( [self.isCompanyName boolValue] ) {
			if ( ![self.categories isSubsetOfSet:company.categories] )
				[self addCategories:company.categories];
		}
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


#pragma mark Categories

- (void)syncCategories {
	for ( BGCompany *company in self.companies ) {
		[company syncCategories];
	}
}

- (void)addCategoriesObject:(BGCategory *)value 
{   
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveCategories] addObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	
	[self syncCategories];
}

- (void)removeCategoriesObject:(BGCategory *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveCategories] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	
	[self syncCategories];
}

@end
