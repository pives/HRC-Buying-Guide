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
#import "Company.h"
#import "Brand.h"
#import "Category.h"

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
    
    return [context entitiesWithName:@"Company"];
    
}

NSArray* allCategories(NSManagedObjectContext* context){
    
    return [context entitiesWithName:@"Category"];
    
}

NSArray* allBrands(NSManagedObjectContext* context){
    
    return [context entitiesWithName:@"Brands"];
    
}

#pragma mark -
#pragma mark New Entities 

Brand* brandWithName(NSString* name, NSManagedObjectContext* context){
    
    return [context retrieveOrCreateEntityWithName:@"Brand" whereKey:@"name" like:name];
}

Category* categoryWithName(NSString* name, NSManagedObjectContext* context){
    
    return [context retrieveOrCreateEntityWithName:@"Category" whereKey:@"name" like:name];
}

Company* companyWithName(NSString* name, NSManagedObjectContext* context){
    
    return [context retrieveOrCreateEntityWithName:@"Company" whereKey:@"name" like:name];
}

Company* companyWithID(NSNumber* ID, NSManagedObjectContext* context){
    
    return [context retrieveOrCreateEntityWithName:@"Company" whereKey:@"ID" equalToObject:ID];
}
