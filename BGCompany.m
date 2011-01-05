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
		BGCompanyInheritedKeys = [[NSArray alloc] initWithObjects:@"includeInIndex", @"rating", @"ratingLevel", @"partner", @"nonResponder", nil];
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

@end