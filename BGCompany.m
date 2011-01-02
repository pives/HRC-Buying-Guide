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


- (void)setName:(NSString *)value 
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:value];
    [self didChangeValueForKey:@"name"];
	
	self.namefirstLetter = [value uppercaseFirstCharacter];
}

@end