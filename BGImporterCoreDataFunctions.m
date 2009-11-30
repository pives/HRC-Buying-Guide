//
//  BGImporterCoreDataFunctions.m
//  BuyingGuide
//
//  Created by Corey Floyd on 11/20/09.
//  Copyright 2009 Flying Jalapeño Software. All rights reserved.
//

#import "BGImporterCoreDataFunctions.h"
#import "CoreDataFunctions.h"
#import "NSString+extensions.h"
#import "NSArray+blocks.h"
#import "NSSet+blocks.h"
#import "NSManagedObjectContext+Extensions.h"
#import "Company.h"
#import "Brand.h"
#import "Category.h"


static int categoryIndex = 5;
static int IDIndex = 0;
static int nameIndex = 8;
static int officialNameIndex = 2;
static int brandsIndex = 9;
static int partnerIndex = 14;
static int ratingIndex = 7;

static int unknownRating = -1;
static NSString* unknownRatingString = @"?";


NSError* save(NSManagedObjectContext* context) {
    
    NSError *error = nil;
    
    if (![context save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
    return error;
}



#pragma mark -
#pragma mark Process CSV

NSError* importUsingCSV(NSManagedObjectContext* context){
    
    NSURL* url = [[[NSFileManager defaultManager] URLsForDirectory:NSUserDirectory inDomains:NSLocalDomainMask] objectAtIndex:0];
    url = [url URLByAppendingPathComponent:@"coreyfloyd/Development/ProductionProjects/HRC/BuyingGuide/bgdata.csv"];
    
    NSString* csv = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSArray* csvRows = [csv csvRows];
    csvRows = [csvRows mutableCopy]; 
    [(NSMutableArray*)csvRows removeObjectAtIndex:0]; //getting rid of headers! 
    
    NSError* saveError;
    
    for(NSArray* eachRow in csvRows){
        
        processRowIntoContext(eachRow, context);
        saveError = save(context);
        //NSLog(@"%@",[saveError description]);
        
    }
    
    return saveError;
}


void processRowIntoContext(NSArray *row, NSManagedObjectContext* context){
    
    Company* theCompany = companyWithRow(row, context);
    
    Category* theCategory = categoryWithName([row objectAtIndex:categoryIndex], context);
    
    theCompany = companyByaddingCategoryToCompany(theCategory, theCompany);
    
    NSSet* brands = brandsWithString([row objectAtIndex:brandsIndex], context);
    
    Brand* companyBrand = brandWithName(theCompany.name, context);
    companyBrand.isCompanyName = [NSNumber numberWithBool:YES];
    NSString* index = [companyBrand.name substringToIndex:1];
    companyBrand.namefirstLetter = index;
    
    brands = [brands setByAddingObject:companyBrand];
    
    theCompany = companyByaddingBrandsToCompany(brands, theCompany);
    
    associateBrandsWithCategory(brands, theCategory);
    
    return;
    
}


#pragma mark -
#pragma mark adding company data

NSNumber* ratingLevelForScore(int rating){
    
    NSNumber* level;
    
    if(rating<46)
        level = [NSNumber numberWithInt:2];
    else if(rating<80)
        level = [NSNumber numberWithInt:1];
    else 
        level = [NSNumber numberWithInt:0];
    
    return level;
}


Company* companyWithRow(NSArray* row, NSManagedObjectContext* context){
    
    Company* theCompany;
    NSString* IDString = [row objectAtIndex:IDIndex];
    NSNumber* ID = [NSNumber numberWithInt:[IDString intValue]];
    
    theCompany = companyWithID(ID, context);
    
    if(theCompany.name == nil){
        
        theCompany.name = [row objectAtIndex:nameIndex];
        
        NSString* index = [theCompany.name substringToIndex:1];
        theCompany.namefirstLetter = [index capitalizedString];
        
        if([[row objectAtIndex:ratingIndex] doesContainString:unknownRatingString]){
            
            theCompany.rating = [NSNumber numberWithInt:unknownRating];
            theCompany.ratingLevel = ratingLevelForScore(unknownRating);
            
            
        }else{
            
            theCompany.rating = [NSNumber numberWithInt:[[row objectAtIndex:ratingIndex] intValue]];
            theCompany.ratingLevel = ratingLevelForScore([[row objectAtIndex:ratingIndex] intValue]);
            
        }
        
        theCompany.officialName = [row objectAtIndex:officialNameIndex];
        
        if([[row objectAtIndex:partnerIndex] length]>0)
            theCompany.partner = [NSNumber numberWithBool:YES];
        else
            theCompany.partner = [NSNumber numberWithBool:NO];
        
        
    }
    
    return theCompany;
}


Company* companyByaddingCategoryToCompany(Category* aCategory, Company* aCompany){
    
    [aCompany addCategoriesObject:aCategory];
    [aCategory addCompaniesObject:aCompany];
    
    return aCompany;
}


Company* companyByaddingBrandsToCompany(NSSet* someBrands, Company* aCompany){
    
    [someBrands setValue:aCompany forKey:@"company"];
    [aCompany addBrands:someBrands];
    
    return aCompany;
}



NSSet* brandsWithString(NSString* string, NSManagedObjectContext* context){
    
    NSMutableSet* brands = [NSMutableSet set];
    
    // Characters that are important to the parser
    NSMutableCharacterSet *importantCharactersSet = (id)[NSMutableCharacterSet characterSetWithCharactersInString:@";"];    
    
    NSScanner *scanner = [NSScanner scannerWithString:string];
    [scanner setCharactersToBeSkipped:nil];
    
    while ( ![scanner isAtEnd] ) {        
        
        NSString *tempString;
        if ( [scanner scanUpToCharactersFromSet:importantCharactersSet intoString:&tempString] ) {
            if(![tempString isEmpty]){
                
                tempString = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                Brand* brand = brandWithName(tempString, context);
                NSString* index = [brand.name substringToIndex:1];
                brand.namefirstLetter = [index capitalizedString];
                brand.isCompanyName = [NSNumber numberWithBool:NO];
                [brands addObject:brand];
                
            }
        }
        [scanner scanString:@";" intoString:NULL];
    }
    
    return brands;
    
}

void associateBrandsWithCategory(NSSet* someBrands, Category* aCategory){
    
    
    [someBrands each:^(id eachBrand){
        
        [(Brand*)eachBrand addCategoriesObject:aCategory];
        
    }];
    
    [aCategory addBrands:someBrands];
}
