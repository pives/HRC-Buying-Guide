//
//  DataSource.h
//  PagingScrollView
//
//  Created by Matt Gallagher on 24/01/09.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import "BGCompany.h"
#import "BGCategory.h"

@interface HRCBrandTableDataSource : NSObject
{
	NSDictionary *data;
}
@property(nonatomic,retain)NSDictionary *data;
@property(nonatomic, readonly)BGCompany* company;
@property(nonatomic, readonly)BGCategory* category;


- (id)initWithCompany:(BGCompany*)aCompany category:(BGCategory*)aCategory;
- (void)setCompany:(BGCompany*)aCompany category:(BGCategory*)aCategory;

- (NSInteger)numDataPages;
- (int)pageOfCategory:(BGCategory*)aCategory;
- (int)pageOfStartingSelectedCategory;

@end
