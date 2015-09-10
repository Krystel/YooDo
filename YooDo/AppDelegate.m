//
//  AppDelegate.m
//  YooDo
//
//  Created by Krystel Chaccour on 9/10/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import "AppDelegate.h"
#import "Main Page/MainPage.h"
#import "Welcome Page/WelcomePage.h"

@interface AppDelegate ()
{
    NSString *writableDBPath;
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Create/Connect to database
    [self createEditableCopyOfDatabaseIfNeeded];
    self.database = [FMDatabase databaseWithPath:writableDBPath];
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    [self retrieveCredentials];
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Credentials
#pragma mark -
/*
 ** Check if plist exists, if it doesn't redirect to Welcome page as root window, else retrieve user's credentials and if valid load main controller into root window
 */
-(void)retrieveCredentials
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"Credentials.plist"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath])
    {
        plistPath = [[NSBundle mainBundle] pathForResource:@"Credentials" ofType:@"plist"];
    }
    
    NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    if ([dict objectForKey:@"UserName"])
    {
        MainPage *mainPage = [[MainPage alloc] init];
        mainPage.userName = [dict objectForKey:@"UserName"];
        [self.window setRootViewController:mainPage];
    }
    else
    {
        WelcomePage *welcomePage = [[WelcomePage alloc] init];
        [self.window setRootViewController:welcomePage];
    }
}

#pragma mark - Database

/*
 ** Creates a writable copy of the bundled default database in the application Documents directory.
 */
- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"TodoList.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success)
        return;
    
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"TodoList.sqlite"];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    //    [self saveContext];
}

@end
