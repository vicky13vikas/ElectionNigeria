//
//  UIViewController+RevealViewSetup.m
//  ElectionNigeria
//
//  Created by Vikas Kumar on 30/07/14.
//  Copyright (c) 2014 Vikas Kumar. All rights reserved.
//

#import "UIViewController+RevealViewSetup.h"
#import "SWRevealViewController.h"

#define LOCKING_VIEW_TAG 1125

@implementation UIViewController (RevealViewSetup)

- (void)setUpViewController
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btn setBackgroundImage:[UIImage imageNamed:@"menu"] forState:UIControlStateNormal];
    [btn addTarget:self.revealViewController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    self.revealViewController.delegate = self;
}



-(void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position
{
    if (revealController.frontViewPosition == FrontViewPositionRight) {
        
        //LockingView is added to disable the userInteraction for the subviews for the views which goes below the sidebar view.
        
        UIView *lockingView = [[UIView alloc] initWithFrame:revealController.frontViewController.view.frame];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:revealController action:@selector(revealToggle:)];
        [lockingView addGestureRecognizer:tap];
        [lockingView addGestureRecognizer:self.revealViewController.panGestureRecognizer];
        
        [lockingView setTag:LOCKING_VIEW_TAG];
        [revealController.frontViewController.view addSubview:lockingView];
    }
    else
    {
        [[revealController.frontViewController.view viewWithTag:LOCKING_VIEW_TAG] removeFromSuperview];
    }
}

- (BOOL)shouldAutorotate
{
    return NO;
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}



@end
