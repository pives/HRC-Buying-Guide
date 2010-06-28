//
//  Company+Extensions.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BGCompany.h"

@class BGCategory;


@interface BGCompany(Extensions)

@property (nonatomic, readonly)NSString* ratingFormatted;
@property (nonatomic, readonly)NSArray* categoriesSortedAlphabetically;

/*

- (NSInteger)numDataPages;
- (int)pageOfCategory:(Category*)aCategory;
- (int)pageOfStartingSelectedCategory;
*/

@end


@interface BGCompany(BrandsTable)

//@property (nonatomic, retain)Category* selectedCategory;


@end

