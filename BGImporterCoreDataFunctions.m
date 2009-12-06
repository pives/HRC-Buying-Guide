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
    
    NSURL* url = [[NSBundle mainBundle] URLForResource: @"bgdata" withExtension:@"csv"];
    
    //[[[NSFileManager defaultManager] URLsForDirectory:NSUserDirectory inDomains:NSLocalDomainMask] objectAtIndex:0];
    //url = [url URLByAppendingPathComponent:@"coreyfloyd/Development/ProductionProjects/HRC/BuyingGuide/bgdata.csv"];
    
    NSString* csv = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSArray* csvRows = [csv csvRows];
    csvRows = [csvRows mutableCopy]; 
    [(NSMutableArray*)csvRows removeObjectAtIndex:0]; //getting rid of headers! 
    
    NSError* saveError = nil;
    
    for(NSArray* eachRow in csvRows){
        
        /*Company* aC =*/ processRowIntoContext(eachRow, context);
        //NSLog(@"%@", [aC description]);
        
        /*
        for (Brand* eachBrand in [aC brands])
             NSLog(@"%@", [eachBrand description]);
        */
        saveError = save(context);
        
        if(saveError != nil){
            NSLog(@"%@",[saveError description]);
            saveError = nil;
        }
        
    }
    
    addDisplayFriendlyCategoryNames(context);
    addPartnerSpecialCases(context);
    
    return saveError;
}


void addPartnerSpecialCases(NSManagedObjectContext* context){

    
    Company* chase = [context entityWithName:@"Company" whereKey:@"name" contains:@"Chase"];
    
    chase.partner = [NSNumber numberWithBool:NO];
    
    for(Brand* eachBrand in chase.brands){
        
        
        if([eachBrand.name isEqualToString:@"Chase"]){
            
            eachBrand.partner = [NSNumber numberWithBool:YES];
            
        }else{
            
            eachBrand.partner = [NSNumber numberWithBool:NO];
        }
        
        
    }
    
    Company* diageo = [context entityWithName:@"Company" whereKey:@"name" contains:@"Diageo"];

    diageo.partner = [NSNumber numberWithBool:NO];
    
    for(Brand* eachBrand in diageo.brands){
        
        if([eachBrand.name doesContainString:@"Beaulieu"]){
            
            eachBrand.partner = [NSNumber numberWithBool:YES];
            
        }else{
            
            eachBrand.partner = [NSNumber numberWithBool:NO];
        }
        
        
    }
        
    Company* toyota = [context entityWithName:@"Company" whereKey:@"name" contains:@"Toyota"];
    
    toyota.partner = [NSNumber numberWithBool:NO];
    
    for(Brand* eachBrand in toyota.brands){
        
        if([eachBrand.name doesContainString:@"Lexus"]){
            
            eachBrand.partner = [NSNumber numberWithBool:YES];
            
        }else{
            
            eachBrand.partner = [NSNumber numberWithBool:NO];
        }
        
        
    }
    
    Company* jj = [context entityWithName:@"Company" whereKey:@"name" contains:@"Johnson & Johnson"];
    
    jj.partner = [NSNumber numberWithBool:NO];
    
    for(Brand* eachBrand in jj.brands){
        
        if([eachBrand.name doesContainString:@"Tylenol-PM"]){
            
            eachBrand.partner = [NSNumber numberWithBool:YES];
            
        }else{
            
            eachBrand.partner = [NSNumber numberWithBool:NO];
        }
        
        
    }
    

    save(context);
    
}


Company* processRowIntoContext(NSArray *row, NSManagedObjectContext* context){
    
    Company* theCompany = companyWithRow(row, context);
    
    Category* theCategory = categoryWithName([row objectAtIndex:categoryIndex], context);
    
    theCompany = companyByaddingCategoryToCompany(theCategory, theCompany);
    
    NSSet* brands = brandsWithString([row objectAtIndex:brandsIndex], context);
    
    Brand* companyBrand = brandWithName(theCompany.name, context);
    companyBrand.isCompanyName = [NSNumber numberWithBool:YES];
    
    companyBrand.namefirstLetter = indexCharForName(companyBrand.name);
    companyBrand.nameSortFormatted = [companyBrand.name stringByRemovingArticlePrefixes];
    
    brands = [brands setByAddingObject:companyBrand];
    
    theCompany = companyByaddingBrandsToCompany(brands, theCompany);
    
    associateBrandsWithCategory(brands, theCategory);
    
    return theCompany;
    
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


Company* companyWithRow(NSArray* row, NSManagedObjectContext* context){
    
    Company* theCompany;
    NSString* IDString = [row objectAtIndex:IDIndex];
    NSNumber* ID = [NSNumber numberWithInt:[IDString intValue]];
    
    theCompany = companyWithID(ID, context);
    
    if(theCompany.name == nil){
        
        theCompany.name = [row objectAtIndex:nameIndex];
        theCompany.namefirstLetter = indexCharForName(theCompany.name);
                
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
    [someBrands setValue:aCompany.partner forKey:@"partner"];
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
    
    return brands;
    
}

void associateBrandsWithCategory(NSSet* someBrands, Category* aCategory){
    
    
    [someBrands each:^(id eachBrand){
        
        [(Brand*)eachBrand addCategoriesObject:aCategory];
        
    }];
    
    [aCategory addBrands:someBrands];
}

void addDisplayFriendlyCategoryNames(NSManagedObjectContext* context){
    
    
    NSArray* categories = allCategories(context);

    for(Category *eachCategory in categories){
        
        
        NSString* displayName;
        
        if([eachCategory.name doesContainString:@"Road"]){
            
            displayName = @"Automotive";
            
        }else if([eachCategory.name doesContainString:@"Trip"]){
            
            displayName = @"Travel and Leisure";
            
        }else if([eachCategory.name doesContainString:@"Filling"]){
            
            displayName = @"Oil & Gas";
            
        }else if([eachCategory.name doesContainString:@"Shop"]){
            
            displayName = @"Retailers";
            
        }else if([eachCategory.name doesContainString:@"Insurance"]){
            
            displayName = @"Insurance";
            
        }else if([eachCategory.name doesContainString:@"Entertained"]){
            
            displayName = @"Entertainment";
            
        }else if([eachCategory.name doesContainString:@"Eating"]){
            
            displayName = @"Restaurants";
            
        }else if([eachCategory.name doesContainString:@"Mail"]){
            
            displayName = @"Shipping";
            
        }else if([eachCategory.name doesContainString:@"Newsstand"]){
            
            displayName = @"Newsstand";
            
        }else{
            
            displayName = eachCategory.name;
            
        }        
     
        eachCategory.nameDisplayFriendly = displayName;
    }
    
    save(context);
}
