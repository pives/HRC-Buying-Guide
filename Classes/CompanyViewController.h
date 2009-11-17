//
//  CompanyViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Company;
@class DataSource;
@class Category;
@class PagingScrollViewController;

@interface CompanyViewController : UIViewController {
    
    Company* company;
    
    UILabel* nameLabel;
    UILabel* scoreLabel;
    
    DataSource* data;
    
    PagingScrollViewController* brands;

}
@property(nonatomic,retain)Company *company;
@property(nonatomic,assign)IBOutlet UILabel *nameLabel;
@property(nonatomic,assign)IBOutlet UILabel *scoreLabel;
@property(nonatomic,retain)IBOutlet DataSource *data;
@property(nonatomic,retain)IBOutlet PagingScrollViewController *brands;



- (id)initWithCompany:(Company*)aCompany category:(Category*)aCategory;


@end
