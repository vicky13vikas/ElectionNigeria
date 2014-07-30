//
//  UIViewController+RevealViewSetup.h
//  ElectionNigeria
//
//  Created by Vikas Kumar on 30/07/14.
//  Copyright (c) 2014 Vikas Kumar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (RevealViewSetup)


/*!
 @abstract This method does the following:
 1. add top left menu button to the navigation item.
 2. Add pan gesture for showing and hiding the side bar menu.
 
 Call this method for the viewcontrollers which needs the sidebar viewcontroller.
 */
- (void)setUpViewController;

@end
