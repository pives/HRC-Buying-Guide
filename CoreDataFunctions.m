//
//  CoreDataFunctions.m
//  BGImporter
//
//  Created by Corey Floyd on 11/16/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "CoreDataFunctions.h"

#import "NSString+extensions.h"
#import "NSManagedObjectContext+Extensions.h"
#import "BGCompany.h"
#import "BGBrand.h"
#import "BGCategory.h"

/*
static int categoryIndex = 5;
static int IDIndex = 0;
static int nameIndex = 8;
static int officialNameIndex = 2;
static int brandsIndex = 9;
static int partnerIndex = 14;
static int ratingIndex = 7;

static int unknownRating = -1;
static NSString* unknownRatingString = @"?";
*/


#pragma mark -
#pragma mark All Entities


NSArray* allCompanies(NSManagedObjectContext* context){
    
    return [context entitiesWithName:@"BGCompany"];
    
}

NSArray* allCategories(NSManagedObjectContext* context){
    
    return [context entitiesWithName:@"BGCategory"];
    
}

NSArray* allBrands(NSManagedObjectContext* context){
    
    return [context entitiesWithName:@"BGBrands"];
    
}

#pragma mark -
#pragma mark New Entities 

BGBrand* brandWithName(NSString* name, NSManagedObjectContext* context){
    
    return [context retrieveOrCreateEntityWithName:@"BGBrand" whereKey:@"name" caseInsensitiveLike:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

BGCategory* categoryWithName(NSString* name, NSManagedObjectContext* context){
    
    return [context retrieveOrCreateEntityWithName:@"BGCategory" whereKey:@"name" caseInsensitiveLike:[name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

BGCompany* companyWithName(NSString* name, NSManagedObjectContext* context){
    
    return [context retrieveOrCreateEntityWithName:@"BGCompany" whereKey:@"name" like:name];
}

BGCompany* companyWithID(NSNumber* ID, NSManagedObjectContext* context){
    
    return [context retrieveOrCreateEntityWithName:@"BGCompany" whereKey:@"remoteID" equalToObject:ID];
}
