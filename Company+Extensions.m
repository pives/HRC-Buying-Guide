//
//  Company+Extensions.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "Company+Extensions.h"
#import "BGCategory.h"
#import "NSObject+AssociatedObjects.h"

//static NSString* categoryKey = @"category";

@implementation BGCompany(Extensions)

- (NSString*)ratingFormatted{
    
    NSString* r;
    
    if([self.rating intValue] == -1){
        
        r = @"?";
    }else {
        r = [self.rating description];
    }

    
    return r;
    
}

- (NSArray*)categoriesSortedAlphabetically{
    
    NSSortDescriptor* sort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES selector:@selector(caseInsensitiveCompare:)];
    
    NSArray* cats = [[self.categories allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
    
    [sort release];
    
    return cats;
}

@end



@implementation BGCompany(BrandsTable)


/*
- (void)setSelectedCategory:(Category*)aCategory{
	
	[self associateValue:aCategory withKey:categoryKey];
	
}

- (Category*)selectedCategory{
	
	return [self associatedValueForKey:categoryKey];
}

- (NSInteger)numDataPages{
	
	return [[self.categories count] intValue]+1;
}

- (int)pageOfCategory:(Category*)aCategory{
	
	return [self.categoriesSortedAlphabetically indexOfObject:aCategory]+1;
}

- (int)pageOfStartingSelectedCategory{
	
	return [self pageOfCategory:self.selectedCategory];
}

 */
@end