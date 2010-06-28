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
@class HRCBrandTableDataSource;
@class BGCategory;
@class PagingScrollViewController;

@interface CompanyViewController : UIViewController <UIActionSheetDelegate ,MFMailComposeViewControllerDelegate, FacebookAgentDelegate> {
    
    BGCompany* company;
    
    UILabel* nameLabel;
    UILabel* scoreLabel;
    UIView* scoreBackgroundColor;
    UIImageView* partnerIcon;
    
    HRCBrandTableDataSource* data;
    PagingScrollViewController* brands;
    
    FacebookAgent* agent;

}
@property(nonatomic,retain)BGCompany *company;
@property(nonatomic,assign)IBOutlet UILabel *nameLabel;
@property(nonatomic,assign)IBOutlet UILabel *scoreLabel;
@property(nonatomic,retain)HRCBrandTableDataSource *data;
@property(nonatomic,retain)IBOutlet PagingScrollViewController *brands;
@property(nonatomic,assign)IBOutlet UIView *scoreBackgroundColor;
@property(nonatomic,assign)IBOutlet UIImageView *partnerIcon;
@property(nonatomic,retain)FacebookAgent *agent;

- (IBAction)showScoreCard;

- (id)initWithCompany:(BGCompany*)aCompany category:(BGCategory*)aCategory;

- (void)setCompany:(BGCompany*)aCompany category:(BGCategory*)aCategory;

- (void)layoutPartnerImageAndCompanyLabel;

@end
