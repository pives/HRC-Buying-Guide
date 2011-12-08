//
//  CompanyScoreCardViewController.h
//  BuyingGuide
//
//  Created by Corey Floyd on 11/17/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BGCompany;

@interface CompanyScoreCardViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,NSFetchedResultsControllerDelegate>{

}

@property (nonatomic, retain) NSFetchedResultsController *fetchedResultsController;
@property(nonatomic,retain)IBOutlet UITableView *tableView;
@property(nonatomic,retain)UILabel *totalLabel;
@property(nonatomic,retain)IBOutlet UIView *scoreBGView;
@property(nonatomic,retain)IBOutlet UILabel *scoreLabel;
@property(nonatomic,retain)IBOutlet UIView *finalTotalBGView;
@property(nonatomic,retain)BGCompany *company;

- (id)initWithCompany:(BGCompany*)aCompany;
- (void)fetchAndReload;


@end
