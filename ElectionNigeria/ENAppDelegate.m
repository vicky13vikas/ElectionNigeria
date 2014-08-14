//
//  ENAppDelegate.m
//  ElectionNigeria
//
//  Created by Vikas Kumar on 29/07/14.
//  Copyright (c) 2014 Vikas Kumar. All rights reserved.
//

#import "ENAppDelegate.h"
#import "ENSignInViewController.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation ENAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    [self setAppearance];
    
    if(![[NSUserDefaults  standardUserDefaults] valueForKey:ENFirstTimeLaunchCompleteUserDefaultsKey])
    {
        if(isIpad())
            self.window.rootViewController = [[UIStoryboard storyboardWithName:@"SignInStoryboard" bundle:nil] instantiateInitialViewController];
        else
            self.window.rootViewController = [[UIStoryboard storyboardWithName:@"SignInStoryboard" bundle:nil] instantiateInitialViewController];
    }

    
    return YES;
}

- (void)setAppearance
{
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.barTintColor = [UIColor colorWithRed:36.0/255.0f green:176.0f/255.0f blue:112.0/255.0f alpha:1.0f];
    [navBar setTintColor:[UIColor whiteColor]];
    [navBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL wasHandled = NO;

    if([[url scheme] isEqualToString:@"fb850153414997555"])
    {
        wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    }
    else if([[url scheme] isEqualToString:@"twitternigeriaelection"])
    {
        NSDictionary *d = [self parametersDictionaryFromQueryString:[url query]];
        NSString *token = d[@"oauth_token"];
        NSString *verifier = d[@"oauth_verifier"];
        
        ENSignInViewController *vc = (ENSignInViewController *)[[(UINavigationController*)[[self window] rootViewController] viewControllers] firstObject];
        [vc setOAuthToken:token oauthVerifier:verifier];
        wasHandled = YES;
    }
    
    return wasHandled;
}


- (NSDictionary *)parametersDictionaryFromQueryString:(NSString *)queryString {
    
    NSMutableDictionary *md = [NSMutableDictionary dictionary];
    
    NSArray *queryComponents = [queryString componentsSeparatedByString:@"&"];
    
    for(NSString *s in queryComponents) {
        NSArray *pair = [s componentsSeparatedByString:@"="];
        if([pair count] != 2) continue;
        
        NSString *key = pair[0];
        NSString *value = pair[1];
        
        md[key] = value;
    }
    
    return md;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
