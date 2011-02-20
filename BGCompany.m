// 
//  Company.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/19/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "BGCompany.h"
#import "NSString+extensions.h"
#import "BGBrand.h"
#import "BGCategory.h"

@interface BGCompany (CoreDataGeneratedPrimitiveAccessors)

- (NSString *)primitiveName;
- (void)setPrimitiveName:(NSString *)value;

- (NSMutableSet*)primitiveCategories;
- (void)setPrimitiveCategories:(NSMutableSet*)value;

@end

@implementation BGCompany 

@dynamic rating;
@dynamic ID;
@dynamic partner;
@dynamic ratingLevel;
@dynamic includeInIndex;
@dynamic namefirstLetter;
@dynamic name;
@dynamic brands;
@dynamic categories;
@dynamic nonResponder;

static const NSArray *BGCompanyInheritedKeys;

+ (void)initialize {
	if ( self == [BGCompany class] ) {
		BGCompanyInheritedKeys = [[NSArray alloc] initWithObjects:@"rating", @"ratingLevel", nil];
	}
}

- (void)setValue:(id)value forKey:(NSString *)key {
	[super setValue:value forKey:key];
	if ( [BGCompanyInheritedKeys containsObject:key] ) {
		for ( BGBrand *brand in self.brands ) {
			[brand setValue:value forKey:key];
		}
	}
}

- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:value];
    [self didChangeValueForKey:@"name"];
	
	self.namefirstLetter = [value uppercaseFirstCharacter];
}


#pragma mark Categories

- (void)syncCategories {
	[self removeCategories:self.categories];
	for (BGBrand *brand in self.brands) {
		if ( ![brand.categories isSubsetOfSet:self.categories] )
			[self addCategories:brand.categories];
	}
}

- (void)updateCompanyBrandsWithCategory:(BGCategory *)category {
	for (BGBrand *brand in self.brands) {
		if ( [brand.isCompanyName boolValue] ) {
			NSSet *brandCategories = brand.categories;
			if ( ![brandCategories containsObject:category] ) {
				[brand removeCategories:brandCategories];
				[brand addCategoriesObject:category];
			}
		}
	}
}


- (void)addCategoriesObject:(BGCategory *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveCategories] addObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	
	[self updateCompanyBrandsWithCategory:value];
}

- (void)removeCategoriesObject:(BGCategory *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveCategories] removeObject:value];
    [self didChangeValueForKey:@"categories" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
	
	[self updateCompanyBrandsWithCategory:value];
}







@end