//
//  DataSource.m
//  PagingScrollView
//
//  Created by Matt Gallagher on 24/01/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import "HRCBrandTableDataSource.h"
#import "Company.h"
#import "Company+Extensions.h"

NSString* const kCompnayKey = @"CompanyKey";
NSString* const kCategoryKey = @"CategoryKey";
NSString* const kNumberOfCategoriesKey = @"NumOfCats";


@implementation HRCBrandTableDataSource
@synthesize data;

- (void) dealloc
{
    self.data = nil;
    [super dealloc];
}

- (id)initWithCompany:(Company*)aCompany category:(Category*)aCategory{
    
    self = [super init];
	if (self != nil)
	{
		[self setCompany:aCompany category:aCategory];
	}
	return self;
}

- (void)setCompany:(Company*)aCompany category:(Category*)aCategory{
    
	NSMutableDictionary* info = [NSMutableDictionary dictionary];
	
	[info setObject:aCompany forKey:kCompnayKey];
	if(aCategory!=nil)
		[info setObject:aCategory forKey:kCategoryKey];
	
	[info setObject:[NSNumber numberWithInt:[aCompany.categories count]] forKey:kNumberOfCategoriesKey];
	
	self.data = info;
	

}

- (NSInteger)numDataPages
{
	return [(NSNumber*)[data objectForKey:kNumberOfCategoriesKey] intValue]+1;
}

- (Company*)company{
    
    return [data objectForKey:kCompnayKey];
}

- (Category*)category{
    
    return [data objectForKey:kCategoryKey];
    
}

- (int)pageOfCategory:(Category*)aCategory{
    
    return [self.company.categoriesSortedAlphabetically indexOfObject:aCategory]+1;
    
}

- (int)pageOfStartingSelectedCategory{
    
    return [self pageOfCategory:self.category];
}


@end
