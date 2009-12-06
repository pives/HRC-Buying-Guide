//
//  CompanyViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@class Company;
@class DataSource;
@class Category;
@class PagingScrollViewController;

@interface CompanyViewController : UIViewController <UIActionSheetDelegate ,MFMailComposeViewControllerDelegate> {
    
    Company* company;
    
    UILabel* nameLabel;
    UILabel* scoreLabel;
    UIView* scoreBackgroundColor;
    UIImageView* partnerIcon;
    
    DataSource* data;
    
    PagingScrollViewController* brands;

}
@property(nonatomic,retain)Company *company;
@property(nonatomic,assign)IBOutlet UILabel *nameLabel;
@property(nonatomic,assign)IBOutlet UILabel *scoreLabel;
@property(nonatomic,retain)DataSource *data;
@property(nonatomic,retain)IBOutlet PagingScrollViewController *brands;
@property(nonatomic,assign)IBOutlet UIView *scoreBackgroundColor;
@property(nonatomic,assign)IBOutlet UIImageView *partnerIcon;




- (id)initWithCompany:(Company*)aCompany category:(Category*)aCategory;

@end
