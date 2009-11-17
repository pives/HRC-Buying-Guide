//
//  CompanyViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Company;

@interface CompanyViewController : UIViewController {
    
    Company* company;
    
    UILabel* nameLabel;
    UILabel* scoreLabel;

}
@property(nonatomic,retain)Company *company;
@property(nonatomic,assign)IBOutlet UILabel *nameLabel;
@property(nonatomic,assign)IBOutlet UILabel *scoreLabel;


- (id)initWithCompany:(Company*)aCompany;

@end
