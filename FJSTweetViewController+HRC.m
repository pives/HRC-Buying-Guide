//
//  FJSTweetViewController+HRC.m
//  BuyingGuide
//
//  Created by Corey Floyd on 1/22/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import "FJSTweetViewController+HRC.h"
#import "Company.h"

@implementation FJSTweetViewController (HRC)

- (id)initWithCompany:(Company*)aCompany{
	
	NSMutableString* someText = [NSMutableString stringWithString:@"@HRC "];
	[someText appendString:aCompany.name];
	
	self = [self initWithText:someText];
	
	return self;
}

@end
