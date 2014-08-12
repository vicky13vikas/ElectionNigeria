//
// Class:    ENRevealViewController
//
// Project:	 ElectionNigeria
//
// Date:     25/06/14
//
// Author:	 Vikas Kumar
//

#import "ENFacebook.h"
#import <FacebookSDK/FacebookSDK.h>

#define FACEBOOK_PERMISSIONS @[@"public_profile",@"email",@"user_friends",@"user_photos",@"user_birthday"]

@interface ENFacebook ()

@property (nonatomic,strong) void (^connectionCompletionBlock)(BOOL isConnected,NSError *error);
@property (atomic) NSInteger retryCount;
@end

@implementation ENFacebook

@synthesize connectionCompletionBlock;

+(ENFacebook*)sharedInstance
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - FB Interface APIs -

-(BOOL)isAlreadyLoggedIn
{
    BOOL isalreadyLoggedIn = NO;
    // Whenever a person opens the app, check for a cached session
    if ([[FBSession activeSession] isOpen]) {
        isalreadyLoggedIn = YES;
    }
    else
        isalreadyLoggedIn = NO;
    return isalreadyLoggedIn;
}

-(void)openFBSession
{
    // Whenever a person opens the app, check for a cached session
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        
        // If there's one, just open the session silently, without showing the user the login UI
        [FBSession openActiveSessionWithReadPermissions:FACEBOOK_PERMISSIONS
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          // Handler for session state changes
                                          // This method will be called EACH time the session state changes,
                                          // also for intermediate states and NOT just when the session open
                                          if (error)
                                          {
                                              [self sessionStateChanged:session state:state error:error];
                                          }
                                      }];
    }

}

- (void)handleAuthenticationError:(NSError *)error
{
    NSString *alertText;
    NSString *alertTitle;
    if ([FBErrorUtility shouldNotifyUserForError:error] == YES)
    {
        // Error requires people using you app to make an action outside your app to recover
        alertTitle = @"Something went wrong";
        alertText = [FBErrorUtility userMessageForError:error];
        if (self.showErrorFromFaceBook) {
            self.showErrorFromFaceBook(alertTitle, alertText);
        }
        
    }
    else
    {
        if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
        {
            // We need to handle session closures that happen outside of the app
            alertTitle = @"Session Error";
            alertText = @"Your current session is no longer valid. Please log in again.";
            if (self.showErrorFromFaceBook) {
                self.showErrorFromFaceBook(alertTitle, alertText);
            }
        }
        else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
        {
            alertTitle = @"Permission not granted";
            alertText = @"Your post could not be completed because you didn't grant the necessary permissions.";
            if (self.showErrorFromFaceBook) {
                self.showErrorFromFaceBook(alertTitle, alertText);
            }
        }
        else
        {
            // All other errors that can happen need retries
            // Show the user a generic error message
            alertTitle = @"Error";
            alertText = @"Please retry";
            if (self.showErrorFromFaceBook) {
                self.showErrorFromFaceBook(alertTitle, alertText);
            }
        }
    }
}

-(NSString*)fbAccessToken
{
    NSString *accessToken = nil;
    if ([self isAlreadyLoggedIn] ) {
        FBAccessTokenData *accessTokenData = FBSession.activeSession.accessTokenData;
        accessToken = accessTokenData.accessToken;
    }
    return accessToken;
}

-(void)FBUserIDWithCompletionBlock:(void (^)(NSString *userID,NSError *error) )completionBlock;
{
    ENLog(@"INside FBBrowser");
    ENLog(@"FB SESSION = %d",FBSession.activeSession.state);
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        ENLog(@"Inside FBUSERIDCompletionBlock");
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *aUser, NSError *error) {
             if (!error) {
                 completionBlock(aUser.objectID,nil);
             }
             else
                 completionBlock(nil,error);
         }];
    }

}

-(void)connectToFBWithCompletionBlock:(void (^)(BOOL isConnected,NSError *error) )completionBlock
{
    self.connectionCompletionBlock = completionBlock;
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        
        // Close the session and remove the access token from the cache
        // The session state handler (in the app delegate) will be called automatically
        [FBSession.activeSession closeAndClearTokenInformation];
        
        // If the session state is not any of the two "open" states when the button is clicked
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:FACEBOOK_PERMISSIONS
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             
             // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
             [self sessionStateChanged:session state:state error:error];
         }];
    }

        
}

-(void)fetchNumberOfFriendsInFBWithCompletionBlock:(void (^)(NSInteger numberOfFriends,NSError *error) )completionBlock
{
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        // We will request the user's public picture and the user's birthday
        // These are the permissions we need:
        NSArray *permissionsNeeded = @[@"user_friends", @"user_photos",@"user_birthday"];
        // Request the permissions the user currently has
        [FBRequestConnection startWithGraphPath:@"/me/permissions"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if (!error){
                                      // These are the current permissions the user has
                                      NSArray *currentPermissionsData= (NSArray *)[result data];
                                      
                                      // We will store here the missing permissions that we will have to request
                                      NSMutableArray *requestPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                      NSMutableArray *currentPermissions = [[NSMutableArray alloc] initWithArray:@[]];
                                      for (NSDictionary *permission in currentPermissionsData) {
                                          if( [[permission valueForKey:@"status"] isEqualToString:@"granted"] )
                                              [currentPermissions addObject:[permission valueForKey:@"permission"]];
                                      }
                                      for (NSString *permissionNeeded in permissionsNeeded) {
                                          NSInteger index = [currentPermissions indexOfObject:permissionNeeded];
                                          if( index == NSNotFound )
                                          {
                                              [requestPermissions addObject:permissionNeeded];
                                          }
                                      }
                                      // If we have permissions to request
                                      if ([requestPermissions count] > 0){
                                          // Ask for the missing permissions
                                          [self requestForPermission:permissionsNeeded withCompletionHandler:^(NSArray *permissionGranted,NSError *error)
                                           {
                                           if (!error) {
                                               // Permission granted, we can request the user information
                                               [self makeRequestForNumberOFFriendsWithCompletionBlock:completionBlock];
                                           } else {
                                               // An error occurred, we need to handle the error
                                               // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                               [self handleAuthenticationError:error];
                                               ENLog(@"error %@", error.description);
                                               completionBlock(-1,error);
                                           } }];
                                      } else {
                                          // Permissions are present
                                          // We can request the user information
                                          [self makeRequestForNumberOFFriendsWithCompletionBlock:completionBlock];
                                      }
                                      
                                  } else {
                                      // An error occurred, we need to handle the error
                                      // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                      ENLog(@"error %@", error.description);
                                      [self handleAPICallError:error withRetryHandler:^{
                                          [self makeRequestForNumberOFFriendsWithCompletionBlock:completionBlock];
                                      }];
                                  }
                              }];
        

    }
    else
    {
        NSError *loggedOutErr = [NSError errorWithDomain:FacebookSDKDomain
                                                                     code:FBErrorLoggedOut userInfo:nil];

        completionBlock(-1,loggedOutErr);
    }
}

-(void)requestForPermission:(NSArray*)requestPermissions withCompletionHandler:(void (^)(NSArray *permissionGranted,NSError *error))completionBlock
{
    [FBSession.activeSession
     requestNewReadPermissions:requestPermissions
     completionHandler:^(FBSession *session, NSError *error) {
         completionBlock(session.permissions,error);
     }];

}
-(void)makeRequestForNumberOFFriendsWithCompletionBlock:(void (^)(NSInteger numberOfFriends,NSError *error) )completionBlock
{
    FBRequest* friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection,NSDictionary* result,NSError *error) {
                              if (nil == error ) {
                                  //friend list is here
                                  NSArray* friends = [result objectForKey:@"data"];
                                  for (NSDictionary<FBGraphUser>* friend in friends) {
                                      ENLog(@"Friend name: %@", friend.name);
                                  }
                                  completionBlock(friends.count,nil);
                              }else
                              {
                                  //error from FB
                                  ENLog(@"error %@", error.description);
                                  [self handleAPICallError:error withRetryHandler:^{
                                      [self makeRequestForNumberOFFriendsWithCompletionBlock:completionBlock];
                                  }];
                              }
                          }];
    
}

-(void)fetchUserPhotosThumbnailWithSize:(CGSize)thumbnailSize WithCompletionBlock:(void (^)(NSArray *photos,NSError *error) )completionBlock
{
    if (![[FBSession activeSession] isOpen])
    {
        [[FBSession activeSession] openWithCompletionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            [FBRequestConnection startWithGraphPath:@"/me/photos"
                                  completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                      if (!error){
                                          NSArray* photos = [result objectForKey:@"data"];
                                          for (NSDictionary* photo in photos) {
                                              ENLog(@"Friend name: %@", photo);
                                          }
                                          completionBlock(photos,nil);
                                          
                                      }else
                                      {
                                          ENLog(@"error %@", error.description);
                                          [self handleAPICallError:error withRetryHandler:^{
                                              [self fetchUserPhotosThumbnailWithSize:thumbnailSize
                                                                 WithCompletionBlock:completionBlock];
                                          }];
                                          
                                      }
                                  }];
        }];
    }
    else if ([[FBSession activeSession] isOpen])
    {
        [FBRequestConnection startWithGraphPath:@"/me/photos"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  if (!error){
                                      NSArray* photos = [result objectForKey:@"data"];
                                      for (NSDictionary* photo in photos) {
                                          ENLog(@"Friend name: %@", photo);
                                      }
                                      completionBlock(photos,nil);
                                      
                                  }else
                                  {
                                      ENLog(@"error %@", error.description);
                                      [self handleAPICallError:error withRetryHandler:^{
                                          [self fetchUserPhotosThumbnailWithSize:thumbnailSize
                                                             WithCompletionBlock:completionBlock];
                                      }];
                                      
                                  }
                              }];

    }
    
}


-(void)fetchPhotoByID:(NSString*)photoID InSize:(CGSize)photoSize WithCompletionBlock:(void (^)(NSString *photoDownloadedPath,NSError *error) )completionBlock
{
    NSInteger width = photoSize.width;
    NSInteger height = photoSize.height;
    NSString *photopath = [NSString stringWithFormat:@"/%@?width=%d&height=%d",photoID,width,height];
    [FBRequestConnection startWithGraphPath:photopath
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              if (!error){
                                  
                              }else
                              {
                                  ENLog(@"error %@", error.description);
                                  [self handleAPICallError:error withRetryHandler:^{
                                      [self fetchPhotoByID:photoID
                                                    InSize:photoSize
                                       WithCompletionBlock:completionBlock];
                                  }];
                                  
                              }
                          }];


}

#pragma mark - Utility or Internal -
// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        ENLog(@"Session opened");
        // Show the user the logged-in UI
        self.connectionCompletionBlock(YES,error);
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        ENLog(@"Session closed");
        // Show the user the logged-out UI
        if(state == FBSessionStateClosedLoginFailed)
        {
            self.connectionCompletionBlock(NO,error);
            NSString * alertText = NSLocalizedString(@"Please retry", nil);
            NSString * alertTitle = NSLocalizedString(@"Login Failed", nil);
            if( self.showErrorFromFaceBook )
            {
                self.showErrorFromFaceBook(alertTitle,alertText);
            }
        }
    }
    
    // Handle errors
    if (error){
        ENLog(@"Error");
        NSString *alertText;
        NSString *alertTitle;
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
            alertTitle = NSLocalizedStringFromTable(@"Unknown Error", nil, nil);
            alertText = [FBErrorUtility userMessageForError:error];
            if( self.showErrorFromFaceBook )
            {
             self.showErrorFromFaceBook(alertTitle,alertText);
            }
        }
        else
        {
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                //The user refused to log in into your app, either ignore or...
                alertTitle = @"Login cancelled";
                alertText = @"Please Login to use this App";
                if (self.showErrorFromFaceBook) {
                    self.showErrorFromFaceBook(alertTitle, alertText);
                }
                
            }
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession)
            {
                alertTitle = @"Session Error";
                alertText = @"Your current session is no longer valid. Please log in again.";
                if( self.showErrorFromFaceBook )
                {
                    self.showErrorFromFaceBook(alertTitle,alertText);
                }
                // For simplicity, here we just show a generic message for all other errors
                // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
            }
            else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled)
            {
                alertTitle = @"Permission not granted";
                alertText = @"Your post could not be completed because you didn't grant the necessary permissions.";
                if (self.showErrorFromFaceBook) {
                    self.showErrorFromFaceBook(alertTitle, alertText);
                }
            }
            else
            {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                alertTitle = @"Something went wrong";
                alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
                if( self.showErrorFromFaceBook )
                {
                    self.showErrorFromFaceBook(alertTitle,alertText);
                }
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        self.connectionCompletionBlock(NO,error);
    }
}

#pragma mark - Error handling
// Helper method to handle errors during API calls
- (void)handleAPICallError:(NSError *)error withRetryHandler:(void (^)(void))retryHandler
{
    
    // If the user has removed a permission that was previously granted
    if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryPermissions) {
        ENLog(@"Re-requesting permissions");
        // Ask for required permissions.
        NSArray *permissionsNeeded = FACEBOOK_PERMISSIONS;
        [self requestForPermission:permissionsNeeded withCompletionHandler:^(NSArray *permissionGranted,NSError *error)
         {
             if (!error) {
                 // Permission granted, we can request the user information
                 retryHandler();
             } else {
                 // An error occurred, we need to handle the error
                 // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                 ENLog(@"error %@", error.description);
                 ENLog(@"Unexpected error posting to open graph: %@", error);
                 NSString *alertText;
                 NSString *alertTitle;
                 alertTitle = @"Something went wrong";
                 alertText = @"Please try again later.";
                 if (self.showErrorFromFaceBook) {
                     self.showErrorFromFaceBook(alertTitle, alertText);
                 }
             } }];
        return;
    }
    
    // Some Graph API errors need retries, we will have a simple retry policy of one additional attempt
    // We also retry on a throttling error message, a more sophisticated app should consider a back-off period
    _retryCount++;
    if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryRetry ||
        [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryThrottling) {
        if (_retryCount < 2) {
            ENLog(@"Retrying open graph post");
            // Recovery tactic: Call API again.
            retryHandler();
            return;
        } else {
            ENLog(@"Retry count exceeded.");
            return;
        }
    }
    
    NSString *alertText;
    NSString *alertTitle;

    // If the user should be notified, we show them the corresponding message
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Something Went Wrong";
        alertText = [FBErrorUtility userMessageForError:error];
        
    } else {
        // show a generic error message
        ENLog(@"Unexpected error posting to open graph: %@", error);
        alertTitle = @"Something went wrong";
        alertText = @"Please try again later.";
    }
    if (self.showErrorFromFaceBook)
    {
        self.showErrorFromFaceBook(alertTitle,alertText);
    }
}
@end
