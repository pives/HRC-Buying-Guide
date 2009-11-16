//
//  BGCD.m
//  BGCD
//
//  Created by Corey Floyd on 11/15/09.
//  Copyright Flying Jalapeño Software 2009 . All rights reserved.
//

#import <objc/objc-auto.h>

NSManagedObjectModel *managedObjectModel();
NSManagedObjectContext *managedObjectContext();
NSXMLDocument* createXMLDocumentFromURL(NSURL *url);


int main (int argc, const char * argv[]) {
	
    objc_startCollectorThread();
	
	// Create the managed object context
    NSManagedObjectContext *context = managedObjectContext();
	
	// Custom code here...
    
    NSURL* url = [NSURL fileURLWithPath:@"file://localhost/Users/coreyfloyd/Development/ProductionProjects/BuyingGuide/bgdata.xml"];
        
    if(url){
        
        NSXMLDocument* doc = createXMLDocumentFromURL(url);
        NSLog(@"%@", [doc description]);
                
        
    }else{
        NSLog(@"Can't create an URL from file.");
    }
    
       
    
    

	// Save the managed object context
    NSError *error = nil;    
    if (![context save:&error]) {
        NSLog(@"Error while saving\n%@",
              ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        exit(1);
    }
    return 0;
}


NSXMLDocument* createXMLDocumentFromURL(NSURL *url) {
    NSXMLDocument *xmlDoc;
    NSError *err=nil;
    if (url) {
        return nil;
    }
    xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:url
                                                  options:(NSXMLNodePreserveWhitespace|NSXMLNodePreserveCDATA)
                                                    error:&err];
    if (xmlDoc == nil) {
        xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:url
                                                      options:NSXMLDocumentTidyXML
                                                        error:&err];
    }
    if (xmlDoc == nil)  {
        if (err) {
            //[self handleError:err];
        }
    }
    
    if (err) {
        //[self handleError:err];
    }
    
    return xmlDoc;
}



NSManagedObjectModel *managedObjectModel() {
    
    static NSManagedObjectModel *model = nil;
    
    if (model != nil) {
        return model;
    }
    
	NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
	path = [path stringByDeletingPathExtension];
	NSURL *modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"mom"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}



NSManagedObjectContext *managedObjectContext() {
	
    static NSManagedObjectContext *context = nil;
    if (context != nil) {
        return context;
    }
    
    context = [[NSManagedObjectContext alloc] init];
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: managedObjectModel()];
    [context setPersistentStoreCoordinator: coordinator];
    
    NSString *STORE_TYPE = NSSQLiteStoreType;
	
	NSString *path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
	path = [path stringByDeletingPathExtension];
	NSURL *url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
    
	NSError *error;
    NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
    
    if (newStore == nil) {
        NSLog(@"Store Configuration Failure\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
    }
    
    return context;
}

