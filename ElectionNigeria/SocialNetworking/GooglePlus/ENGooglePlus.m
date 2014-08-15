//
// Class:    ENGooglePlus
//
// Project:	 Igloo
//
// Date:     14/03/14
//
// Author:	 Vikas Kumar
//
// Copyright © 2014 Gloopt. All rights reserved..
// Written under contract by Robosoft Technologies Pvt. Ltd.
//

#import "ENGooglePlus.h"

//typedef void (^MyBlockType)(BOOL, *NSError);

typedef void (^CompletionHandler)(bool, NSError *error);

static NSString * const kGooglePlusClientId = @"680343496964-jtdfvastqqlag4437jskn170vcldbime.apps.googleusercontent.com";

@interface ENGooglePlus() <GPPShareDelegate>
{
    CompletionHandler completionBlock;
}

@end

@implementation ENGooglePlus

+ (id)sharedInstance {
    static ENGooglePlus *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(void)googlePlusShareURL:(NSString*)shareURL thumbnailURL:(NSString *)thumbnailImageUrl comment:(NSString*)comment withCompletionHandler:(void (^)(bool success, NSError *error)) completionHandler
{
    [GPPShare sharedInstance].delegate = self;
    [GPPSignIn sharedInstance].clientID = kGooglePlusClientId;
   
    id<GPPShareBuilder> shareBuilder = [[GPPShare sharedInstance] shareDialog];
    
    [shareBuilder setURLToShare:[NSURL URLWithString:shareURL]];
    [shareBuilder setPrefillText:comment];
    [shareBuilder setTitle:nil description:nil thumbnailURL:[NSURL URLWithString:thumbnailImageUrl]];
    
    [shareBuilder open];
    completionBlock = completionHandler;
}

- (void)finishedSharingWithError:(NSError *)error
{
    if(error == nil)
        completionBlock(YES, nil);
    else
        completionBlock(NO, error);
}

@end
