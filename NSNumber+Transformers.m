//
//  NSNumber+Transformers.m
//  BuyingGuide
//
//  Created by Joe Walsh on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSNumber+Transformers.h"
#import "BGCompany.h"

@implementation NSNumber (Transformers)

- (NSNumber *)ratingLevelFromRating {
    
	NSInteger rating = [self integerValue];
    
    NSNumber* level;
    
    if(rating<46)
        level = [NSNumber numberWithInt:BAD_COMPANY_RATING];
    else if(rating<80)
        level = [NSNumber numberWithInt:OK_COMPANY_RATING];
    else 
        level = [NSNumber numberWithInt:GOOD_COMPANY_RATING];
    
    return level;

}


@end
