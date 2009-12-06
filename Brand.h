//
//  Brand.h
//  BuyingGuide
//
//  Created by Corey Floyd on 12/6/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Category;
@class Company;

@interface Brand :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * partner;
@property (nonatomic, retain) NSString * nameSortFormatted;
@property (nonatomic, retain) NSString * namefirstLetter;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isCompanyName;
@property (nonatomic, retain) NSSet* categories;
@property (nonatomic, retain) Company * company;

@end


@interface Brand (CoreDataGeneratedAccessors)
- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)value;
- (void)removeCategories:(NSSet *)value;

@end

