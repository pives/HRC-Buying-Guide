//
//  CompanyViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "FacebookAgent.h"

@class BGCompany;
@class BGCategory;
@class BGBrand;
@class BALabel;

@interface BrandViewController : UIViewController <UIActionSheetDelegate ,MFMailComposeViewControllerDelegate, FacebookAgentDelegate, UITableViewDelegate, UITableViewDataSource> {
    
    BGCompany* company;
    
    UILabel* nameLabel;
    UILabel* scoreLabel;
    UIView* scoreBackgroundColor;
    UIImageView* partnerIcon;
    
    
    FacebookAgent* agent;

}
@property(nonatomic,retain)BGCompany *company;
@property(nonatomic,retain)BGBrand *brand;
@property(nonatomic,retain)BGCategory *category;
@property(nonatomic,retain)NSArray *companyCategories;
@property(nonatomic,retain)NSMutableDictionary *companyCategoryCounts;

@property(nonatomic,retain)IBOutlet UIView *companyView;
@property(nonatomic,retain)IBOutlet BALabel *brandLabel;
@property(nonatomic,retain)IBOutlet UILabel *categoryLabel;
@property(nonatomic,retain)IBOutlet UILabel *scoreLabel;
@property(nonatomic,retain)IBOutlet UILabel *companyLabel;
@property(nonatomic,retain)IBOutlet UIView *scoreBackgroundColor;
@property(nonatomic,retain)IBOutlet UIImageView *partnerIcon;

@property(nonatomic,retain)IBOutlet UITableView *categoriesTableView;
@property(nonatomic,retain)IBOutlet UIView *tableHeaderView;
@property(nonatomic,retain)IBOutlet UIView *findAlternateView;



@property(nonatomic,retain)FacebookAgent *agent;

- (IBAction)showScoreCard;

- (id)initWithBrand:(BGBrand*)aBrand;

- (void)setBrand:(BGBrand*)aBrand;

- (void)layoutPartnerImageAndCompanyLabel;

- (IBAction)showOtherBrandsCategory:(id)sender;

@end
