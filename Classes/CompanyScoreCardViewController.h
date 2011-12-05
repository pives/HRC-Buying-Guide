//
//  CompanyScoreCardViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGCompany;

@interface CompanyScoreCardViewController : UIViewController <UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate>{

    UIToolbar* bar;
    UIActivityIndicatorView* spinner;
}
@property(nonatomic,assign)IBOutlet UIToolbar *bar;
@property(nonatomic,retain)UIActivityIndicatorView *spinner;
@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)UILabel *totalLabel;

- (id)initWithCompany:(BGCompany*)aCompany;
- (IBAction)done;

@end
