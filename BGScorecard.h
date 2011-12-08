//
//  BGScorecard.h
//  BuyingGuide
//
//  Created by Jake O'Brien on 12/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BGCompany;

@interface BGScorecard : NSManagedObject

@property (nonatomic, retain) NSNumber * displayOrder;
@property (nonatomic, retain) NSNumber * policyRating;
@property (nonatomic, retain) NSString * policyDescription;
@property (nonatomic, retain) BGCompany *company;

@end
