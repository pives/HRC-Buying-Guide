//
//  NSNumber+Transformers.m
//  BuyingGuide
//
//  Created by Joe Walsh on 12/22/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSNumber+Transformers.h"


@implementation NSNumber (Transformers)

- (NSNumber *)ratingLevelFromRating {
	NSInteger rating = [self integerValue];
	NSInteger ratingLevel = (100 - rating)/34;
	return [NSNumber numberWithInteger:ratingLevel];
}


@end
