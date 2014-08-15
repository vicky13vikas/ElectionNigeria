//
// Class:    ENGooglePlus
//
// Project:	 ElectionNigeria
//
// Date:     25/06/14
//
// Author:	 Vikas Kumar
//

@import Foundation;
#import <GooglePlus/GooglePlus.h>


/*!
 @class    GTGooglePlus
 @abstract The GTGooglePlus is used to share deatils via Google Plus.
 */
@interface ENGooglePlus : NSObject


/*!
@method    sharedInstance
@abstract  This method creates shared instance.
*/
+ (id)sharedInstance;


/*!
 @abstract Shares the passed data to the Google Plus account.
           If user in not logged in it will ask user for login.
 
 @param shareURL            The URL to be shared
 
 @param thumbnailImageUrl   The image URL to be shared
 
 @param comment             The comments string to be shared
 
 @param completionHandler The block that will be called once the authentication process is complete.
 
        - success  The status of the authentication
            - YES : If Sharing is successful
            - NO : If Sharing failed or error occured
 
        - error   The error received in case of failure.
 */
-(void)googlePlusShareURL:(NSString*)shareURL thumbnailURL:(NSString *)thumbnailImageUrl comment:(NSString*)comment withCompletionHandler:(void (^)(bool success, NSError *error)) completionHandler;


@end
