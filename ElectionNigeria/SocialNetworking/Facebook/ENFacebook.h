//
// Class:    ENFacebook
//
// Project:	 ElectionNigeria
//
// Date:     25/06/14
//
// Author:	 Vikas Kumar
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, FBErrorCodes) {
    FBErrorCantConnect = -1000,
    FBErrorCantFetchFriendList = -1001,
    FBErrorCantFetchPropertyFailed = -1002,
    FBErrorLoggedOut = -1003,
    FBErrorGetFriendCountFailed = -1004,
    FBErrorGetPhotosFailed = -1005,
};

typedef NS_ENUM(NSInteger, FBPropertyIndexes) {
    FBUserPropertyAge = 1,
    FBUserPropertySex,
};

@interface ENFacebook : NSObject

@property (nonatomic,strong) void (^showErrorFromFaceBook)(NSString *alertTitle,NSString *alertText);


+(ENFacebook*)sharedInstance;
/*!
 @method     isAlreadyLoggedIn:
 @abstract   This method to check Facebook login status.
*/
-(BOOL)isAlreadyLoggedIn;

/*!
 @method     openFBSession:
 @abstract   This method opens session if there is a stored access token.
 */
-(void)openFBSession;

/*!
 @method     fbAccessToken:
 @abstract   This method to fetch stored Facebook access token.
 */
-(NSString*)fbAccessToken;

/*!
 @method     FBUserIDWithCompletionBlock:
 @abstract   This method to fetch  Facebook User ID.
 @param      completionBlock  Block that is called on completion Facebook user ID fetch or failure.
 */
-(void)FBUserIDWithCompletionBlock:(void (^)(NSString *userID,NSError *error) )completionBlock;


/*!
 @method     connectToFBWithCompletionBlock:
 @abstract   This method connects to Facebook and returns result or error.
 @param      completionBlock  Block that is called on completion Facebook connect or failure.
 */
-(void)connectToFBWithCompletionBlock:(void (^)(BOOL isConnected,NSError *error) )completionBlock;

/*!
 @method     fetchNumberOfFriendsInFBWithCompletionBlock:
 @abstract   This method connects to Facebook and returns result or error.
 @param      completionBlock  Block that is called on completion Facebook friend count fetch or failure.
 */
-(void)fetchNumberOfFriendsInFBWithCompletionBlock:(void (^)(NSInteger numberOfFriends,NSError *error) )completionBlock;

/*!
 @method     fetchUserPhotosThumbnailWithSize: WithCompletionBlock:
 @abstract   This method fetches user photos thumbnails.
 @param      thumbnailSize  Tumbnail desired size specification.
 @param      completionBlock  Block that is called on completion Facebook thumbnail fetch or error.
 */
-(void)fetchUserPhotosThumbnailWithSize:(CGSize)thumbnailSize WithCompletionBlock:(void (^)(NSArray *photos,NSError *error) )completionBlock;

/*!
 @method     fetchPhotoByID: InSize: WithCompletionBlock:
 @abstract   This method fetches user photo in desired Size.
 @param      photoID  Should be a valid photo ID.
 @param      photoSize Desired size in which photo should be downloaded.
 @param      completionBlock  Block that is called on completion Facebook photo fetch or error.
 */
-(void)fetchPhotoByID:(NSString*)photoID InSize:(CGSize)photoSize WithCompletionBlock:(void (^)(NSString *photoDownloadedPath,NSError *error) )completionBlock;

@end
