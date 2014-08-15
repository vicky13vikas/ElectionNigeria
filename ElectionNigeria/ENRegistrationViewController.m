//
// Class:    ENRegistrationViewController
//
// Project:	 ElectionNigeria
//
// Date:     06/03/14
//
// Author:	 Shishira MS
//


#import "ENRegistrationViewController.h"

#define FOUR_INCH_SCROLL_VIEW_HEIGHT 504

@interface ENRegistrationViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    BOOL isKeyboardVisible;
    BOOL isLinkedInSignUp;
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
//@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
//@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
//@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
//@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
//@property (weak, nonatomic) IBOutlet UILabel *addCouponLabel;
//@property (weak, nonatomic) IBOutlet UITextField *addCodeTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UILabel *orLabel;
@property (weak, nonatomic) IBOutlet UIButton *connectWithLinkedIn;
@property (weak, nonatomic) IBOutlet UILabel *UserSignUpLabel;

- (IBAction)connectWithLinkedIn:(id)sender;
@end

@implementation ENRegistrationViewController

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
    [self.navigationController setNavigationBarHidden:NO];
    [self initialSetUp];
    isLinkedInSignUp = NO;
}

- (void) initialSetUp
{
    [self setTitle:NSLocalizedString(@"Registration", nil)];
    [_cancelButton setTitle:NSLocalizedString(@"Cancel", nil)];
    [_submitButton setTitle:NSLocalizedString(@"Submit", nil) forState:UIControlStateNormal];
    [_connectWithLinkedIn setTitle:NSLocalizedString(@"Sign_Up_using_LinkedIn", nil) forState:UIControlStateNormal];
    [_orLabel setText:NSLocalizedString(@"OR_use_email_address", nil)];
    [_orLabel setTextColor:[UIColor colorWithRed:182.0/255.0 green:182.0/255.0 blue:182.0/255.0 alpha:1]];
    [_UserSignUpLabel setText:NSLocalizedString(@"New_User_Sign_Up", nil)];
}

- (void) presentImagePickerOfSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.sourceType = sourceType;
    photoPicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    photoPicker.delegate = self;
    photoPicker.allowsEditing = NO;
    [self presentViewController:photoPicker animated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self presentImagePickerOfSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if (buttonIndex == 1)
    {
        [self presentImagePickerOfSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
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

#pragma mark - IBActions -

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL) isValidEmailAddress:(NSString*)eMail
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:eMail];
}

- (IBAction)submit:(id)sender
{
    [self tappedOutsideTextField:nil];
    if (_emailTextField.text.length == 0 || _nameTextField.text.length == 0 || _passwordTextField.text.length == 0)
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Fill all Fields" message:@"Please enter all fields before submitting" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        [alert show];
    }
    else if (![self isValidEmailAddress:_emailTextField.text])
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:NSLocalizedString(@"Invalid_Email", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
    }
    else
    {
        NSDictionary *params = @{@"email": _emailTextField.text,
                                 @"first_name": _nameTextField.text,
                                 @"last_name": @"",
                                 @"password" : _passwordTextField.text};
        
        [self submitToServerWithParameters:params];
    }
}

#pragma mark - SERVER REQUEST -

-(void)submitToServerWithParameters:(NSDictionary*)parameters
{
    [self registrationDone];
}

- (void)presentAlertViewForStatusCode:(NSInteger)statusCode
{
    NSString *message = nil;
    switch (statusCode)
    {
        case 400 :
            message = NSLocalizedString(@"Register_400_Error", nil);
            break;
            
        case 401 :
            message = NSLocalizedString(@"Register_401_Error", nil);
            break;
            
        case 409 :
            message = NSLocalizedString(@"Register_409_Error", nil);
            break;
            
        default:
            message = NSLocalizedString(@"Unexpected Error occured", nil);
            break;
    }
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil) message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil] show];
}

-(void)registrationDone
{
    if(isIpad())
        self.view.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil] instantiateInitialViewController];
    else
        self.view.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil] instantiateInitialViewController];
}


- (IBAction)tappedOutsideTextField:(id)sender
{
//    [_firstNameTextField resignFirstResponder];
    [_nameTextField resignFirstResponder];
//    [_userNameTextField resignFirstResponder];
    [_passwordTextField resignFirstResponder];
//    [_confirmPasswordTextField resignFirstResponder];
    [_emailTextField resignFirstResponder];
//    [_addCodeTextField resignFirstResponder];
   
}

#pragma mark - UITextFieldDelegates -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frameToScroll = textField.frame;
    frameToScroll.origin.y += 100;
    [self.scrollView scrollRectToVisible:frameToScroll animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:_nameTextField])
    {
        [_emailTextField becomeFirstResponder];
    }
    
    else if([textField isEqual:_emailTextField])
    {
        [_passwordTextField becomeFirstResponder];
    }
    
    else if([textField isEqual:_passwordTextField])
    {
        [_passwordTextField resignFirstResponder];
        [self submit:nil];
    }
    return YES;
}

@end
