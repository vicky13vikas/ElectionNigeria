//
//  ENSignInViewController.m
//  ElectionNigeria
//
//  Created by Vikas Kumar on 12/08/14.
//  Copyright (c) 2014 Vikas Kumar. All rights reserved.
//

#import <FacebookSDK/Facebook.h>
#import "ENSignInViewController.h"
#import "ENFacebook.h"

#define FOUR_INCH_SCROLL_VIEW_HEIGHT 504

@interface ENSignInViewController ()
{
    BOOL isKeyboardVisible;
}

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation ENSignInViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
     [_forgotPasswordButton setTitleColor:[UIColor colorWithRed:55.0/255.0 green:96.0/255.0 blue:152.0/255.0 alpha:1] forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (isIpad())
    {
        [self.scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height)];
    }
    else
        [self.scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, FOUR_INCH_SCROLL_VIEW_HEIGHT)];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyBoardWillShow:(NSNotification*)notification
{
    if(!isKeyboardVisible)
    {
        isKeyboardVisible = YES;
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGRect frame = _scrollView.frame;
            frame.size.height = frame.size.height - keyboardFrameBeginRect.size.width;
            _scrollView.frame = frame;
        }
        else
        {
            CGRect frame = _scrollView.frame;
            frame.size.height = frame.size.height - keyboardFrameBeginRect.size.height;
            _scrollView.frame = frame;
        }
    }
}

-(void)keyBoardWillHide:(NSNotification*)notification
{
    if(isKeyboardVisible)
    {
        isKeyboardVisible = NO;
        NSDictionary* keyboardInfo = [notification userInfo];
        NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
        CGRect keyboardFrameBeginRect = [keyboardFrameBegin CGRectValue];
        
        if(self.interfaceOrientation == UIInterfaceOrientationLandscapeLeft || self.interfaceOrientation == UIInterfaceOrientationLandscapeRight)
        {
            CGRect frame = _scrollView.frame;
            frame.size.height = frame.size.height + keyboardFrameBeginRect.size.width;
            _scrollView.frame = frame;
        }
        else
        {
            CGRect frame = _scrollView.frame;
            frame.size.height = frame.size.height + keyboardFrameBeginRect.size.height;
            _scrollView.frame = frame;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)singleTap:(id)sender
{
    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegates -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frameToScroll = textField.frame;
    frameToScroll.origin.y += 100;
    [_scrollView scrollRectToVisible:frameToScroll animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:_userNameTextField])
    {
        [_passwordTextField becomeFirstResponder];
    }
    else if([textField isEqual:_passwordTextField])
    {
        [_passwordTextField resignFirstResponder];
        [self signIn:nil];
    }
    return YES;
}

- (BOOL) isValidEmailAddress:(NSString*)eMail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:eMail];
}

-(BOOL)checkLoginParameters
{
    BOOL isParametersOK = YES;
    
    if(_userNameTextField.text.length <= 0)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Email_cannot_be_empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        isParametersOK = NO;
    }
    else  if(_passwordTextField.text.length <= 0)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Password_cannot_be_empty", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        isParametersOK = NO;
    }
    else if (![self isValidEmailAddress:_userNameTextField.text])
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Invalid_Email", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
        isParametersOK = NO;
    }
    
    return isParametersOK;
}

- (IBAction)signIn:(id)sender
{
    [self singleTap:nil];
    if([self checkLoginParameters])
    {
        [self login];
    }
}

- (IBAction)forgotPassword:(id)sender
{
    [self singleTap:nil];
    if(_userNameTextField.text.length <= 0)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Please_Enter_Email", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    else if (![self isValidEmailAddress:_userNameTextField.text])
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Invalid_Email", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    else
    {
        [self forgotPassword];
    }
}

#pragma mark - SERVER REQUEST -

-(void)login
{
    if(isIpad())
        self.view.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateInitialViewController];
    else
        self.view.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateInitialViewController];
}

-(void)forgotPassword
{
   
}


- (IBAction)facebookTapped:(id)sender
{
    [[FBSession activeSession] closeAndClearTokenInformation];
    if([[FBSession activeSession] isOpen])
    {
        [self login];
    }
    else
    {
        [[ENFacebook sharedInstance] connectToFBWithCompletionBlock:^(BOOL isConnected, NSError *error) {
           if(isConnected)
           {
               [self login];
           }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"Login Error" message:@"Unable to connect to Facebook" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }];
    }
}

- (IBAction)twitterTapped:(id)sender {
}

- (IBAction)googleTapped:(id)sender {
}

@end
