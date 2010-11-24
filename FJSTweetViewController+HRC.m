//
//  FJSTweetViewController+HRC.m
//  BuyingGuide
//
//  Created by Corey Floyd on 1/22/10.
//  Copyright 2010 Flying Jalapeño Software. All rights reserved.
//

#import "FJSTweetViewController+HRC.h"
#import "BGCompany.h"
#import "NSString+extensions.h"

@implementation FJSTweetViewController (HRC)

- (id)initWithCompany:(BGCompany*)aCompany{
	
	NSString* someText;
	
    if([aCompany.nonResponder boolValue] == YES){
        
        someText = 
        @"@HRC #LGBT Buyer's Guide gives @%@ an unofficial score of %i%% for not responding to our survey. More: http://bit.ly/buy4eq";

        
    }else{
        
        if([aCompany.ratingLevel intValue] == 0){
            
            someText = 
            @"@HRC #LGBT Buyer's Guide gives @%@ %i%%, one of the highest scores. More: http://bit.ly/buy4eq";
            
            
        }else if([aCompany.ratingLevel intValue] == 1){
            
            someText = 
            @"@HRC #LGBT Buyer's Guide gives @%@ %i%%, a moderate score. More: http://bit.ly/buy4eq";
            
            
        }else{
            
            someText = 
            @"@HRC #LGBT Buyer's Guide gives @%@ %i%%, one of the lowest scores. More: http://bit.ly/buy4eq";
            
        }
        
    }
		
	someText = [NSString stringWithFormat:someText, aCompany.name, [aCompany.rating intValue]];
	
	self = [self initWithText:someText];
	
	return self;
}

@end
