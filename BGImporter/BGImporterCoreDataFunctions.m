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
#import "BGCompany.h"
#import "BGBrand.h"
#import "BGCategory.h"


static int categoryIndex = 0;
static int officialNameIndex = 2;
static int brandsIndex = 3;
static int ratingIndex = 1;
static int nonResponderIndex = 9;
static int idIndex = 7;

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
    
    NSURL* url = [[NSBundle mainBundle] URLForResource: @"bgdata" withExtension:@"csv"];
    
    //[[[NSFileManager defaultManager] URLsForDirectory:NSUserDirectory inDomains:NSLocalDomainMask] objectAtIndex:0];
    //url = [url URLByAppendingPathComponent:@"coreyfloyd/Development/ProductionProjects/HRC/BuyingGuide/bgdata.csv"];
    
    NSString* csv = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSArray* csvRows = [csv csvRows];
    csvRows = [csvRows mutableCopy]; 
    [(NSMutableArray*)csvRows removeObjectAtIndex:0]; //getting rid of headers! 
    
    __block NSError* saveError = nil;
    
    [csvRows enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    
        NSArray* eachRow = (NSArray*)obj;
        
        processRowIntoContext(eachRow, context);
        
        saveError = save(context);
        
        if(saveError != nil){
            NSLog(@"%@",[saveError description]);
            saveError = nil;
        }
        
    }];
    
    addPartnerSpecialCases(context);
        
    return saveError;
}


void addPartnerSpecialCases(NSManagedObjectContext* context){

    
    BGCompany* chase = [context entityWithName:@"BGCompany" whereKey:@"name" contains:@"Chase"];
    
    chase.partner = [NSNumber numberWithBool:NO];
    
    for(BGBrand* eachBrand in chase.brands){
        
        
        if([eachBrand.name isEqualToString:@"Chase"]){
            
            eachBrand.partner = [NSNumber numberWithBool:YES];
            
        }else{
            
            eachBrand.partner = [NSNumber numberWithBool:NO];
        }
        
        
    }
    
    BGCompany* diageo = [context entityWithName:@"BGCompany" whereKey:@"name" contains:@"Diageo"];

    diageo.partner = [NSNumber numberWithBool:NO];
    
    for(BGBrand* eachBrand in diageo.brands){
        
        if([eachBrand.name doesContainString:@"Beaulieu"]){
            
            eachBrand.partner = [NSNumber numberWithBool:YES];
            
        }else{
            
            eachBrand.partner = [NSNumber numberWithBool:NO];
        }
        
        
    }
        
    BGCompany* toyota = [context entityWithName:@"BGCompany" whereKey:@"name" contains:@"Toyota"];
    
    toyota.partner = [NSNumber numberWithBool:NO];
    
    for(BGBrand* eachBrand in toyota.brands){
        
        if([eachBrand.name doesContainString:@"Lexus"]){
            
            eachBrand.partner = [NSNumber numberWithBool:YES];
            
        }else{
            
            eachBrand.partner = [NSNumber numberWithBool:NO];
        }
        
        
    }
    
    BGCompany* jj = [context entityWithName:@"BGCompany" whereKey:@"name" contains:@"Johnson & Johnson"];
    
    jj.partner = [NSNumber numberWithBool:NO];
    
    for(BGBrand* eachBrand in jj.brands){
        
        if([eachBrand.name doesContainString:@"Tylenol-PM"]){
            
            eachBrand.partner = [NSNumber numberWithBool:YES];
            
        }else{
            
            eachBrand.partner = [NSNumber numberWithBool:NO];
        }
        
        
    }
    

    save(context);
    
}


BGCompany* processRowIntoContext(NSArray *row, NSManagedObjectContext* context){
    
    BGCompany* theCompany = companyWithRow(row, context);
    
    BGCategory* theCategory = categoryWithName([row objectAtIndex:categoryIndex], context);
    
    theCompany = companyByaddingCategoryToCompany(theCategory, theCompany);
    
    NSMutableSet* brands = brandsWithString([row objectAtIndex:brandsIndex], context);
    
    BGBrand* companyBrand = brandWithName(theCompany.name, context);
    companyBrand.isCompanyName = [NSNumber numberWithBool:YES];
    companyBrand.namefirstLetter = indexCharForName(companyBrand.name);
    companyBrand.nameSortFormatted = [companyBrand.name stringByRemovingArticlePrefixes];

    [brands addObject:companyBrand];
    theCompany = companyByaddingBrandsToCompany(brands, theCompany);
    
    associateBrandsWithCategory(brands, theCategory);
    
    return theCompany;
    
}


#pragma mark -
#pragma mark adding company data

NSNumber* ratingLevelForScore(int rating){
    
    NSNumber* level;
    
    if(rating<46)
        level = [NSNumber numberWithInt:BAD_COMPANY_RATING];
    else if(rating<80)
        level = [NSNumber numberWithInt:OK_COMPANY_RATING];
    else 
        level = [NSNumber numberWithInt:GOOD_COMPANY_RATING];
    
    return level;
}


NSString* indexCharForName(NSString* aString){
    
    NSString* index = [aString copy];
    index = [index stringByRemovingArticlePrefixes];
    index = [index capitalizedString];
    index = [index substringToIndex:1];
    
    if([index rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location != NSNotFound){
        
        index = @"#";
    }
    
    return [index autorelease];
    
}

NSString* stripPartnerSymbol(NSString* name){
    
    if([name hasSuffix:@"*"])
        return [name stringByDeletingLastCharacter];
    
    return name;

}

BOOL isPartner(NSString* name){
    
    if([name hasSuffix:@"*"])
        return YES;
    
    return NO;
    
}

BGCompany* companyWithRow(NSArray* row, NSManagedObjectContext* context){
    
    BGCompany* theCompany;
       
    NSString* idString = [row objectAtIndex:idIndex];
    int idInt = [idString intValue];
    NSNumber* idNum = [NSNumber numberWithInt:idInt];
    
    theCompany = companyWithID(idNum, context);
    
    NSString* name = [row objectAtIndex:officialNameIndex];
    name = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    theCompany.name = stripPartnerSymbol(name);
    
    theCompany.namefirstLetter = indexCharForName(theCompany.name);
    
    theCompany.rating = [NSNumber numberWithInt:[[row objectAtIndex:ratingIndex] intValue]];
    theCompany.ratingLevel = ratingLevelForScore([[row objectAtIndex:ratingIndex] intValue]);
    
    if([row count] > nonResponderIndex){
        
        theCompany.nonResponder = [NSNumber numberWithBool:YES];
        
    }
    
    if(isPartner(name))
        theCompany.partner = [NSNumber numberWithBool:YES];
    else
        theCompany.partner = [NSNumber numberWithBool:NO];
    
    return theCompany;
}


BGCompany* companyByaddingCategoryToCompany(BGCategory* aCategory, BGCompany* aCompany){
    
    [aCompany addCategoriesObject:aCategory];
    [aCategory addCompaniesObject:aCompany];
    
    return aCompany;
}


BGCompany* companyByaddingBrandsToCompany(NSSet* someBrands, BGCompany* aCompany){
    
    [someBrands enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
    
        BGBrand* eachBrand = (BGBrand*)obj;
        [eachBrand setRating:aCompany.rating];
		[eachBrand setRatingLevel:aCompany.ratingLevel];
		[eachBrand setPartner:aCompany.partner];
        [eachBrand setNonResponder:aCompany.nonResponder];
        
    }];
    
    [aCompany addBrands:someBrands];
    
    return aCompany;
}

NSMutableSet* brandsWithString(NSString* string, NSManagedObjectContext* context){
    
    NSArray* brandsArray = [string componentsSeparatedByString:@";"];
    
   NSMutableArray* brands = [NSMutableArray arrayWithCapacity:[brandsArray count]];
    
    for(NSString* eachName in brandsArray){
        
        NSString* brandName = [eachName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if([brandName length] != 0){
            
            BGBrand* brand = brandWithName(brandName, context);
            brand.namefirstLetter = indexCharForName(brand.name);
            brand.nameSortFormatted = [brand.name stringByRemovingArticlePrefixes];
            brand.isCompanyName = [NSNumber numberWithBool:NO];
            
            [brands addObject:brand];
            
        }
    }
    
    
    NSMutableSet* brandsSet = [NSMutableSet setWithArray:brands];
    
    
    /*
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
                
                BGBrand* brand = brandWithName(tempString, context);
                brand.namefirstLetter = indexCharForName(brand.name);
                brand.nameSortFormatted = [brand.name stringByRemovingArticlePrefixes];
                
                if(brand.nameSortFormatted == nil){
                    
                    NSLog(@"wtf");
                }
                //NSLog(@"%@", [brand description]);
                
                brand.isCompanyName = [NSNumber numberWithBool:NO];
                [brands addObject:brand];
                
            }
        }
        [scanner scanString:@";" intoString:NULL];
    }
     */
    
    
    return brandsSet;
    
}

void associateBrandsWithCategory(NSSet* someBrands, BGCategory* aCategory){
    
    [someBrands each:^(id eachBrand){
        
        [(BGBrand*)eachBrand addCategoriesObject:aCategory];
        
    }];
    
    [aCategory addBrands:someBrands];
}
