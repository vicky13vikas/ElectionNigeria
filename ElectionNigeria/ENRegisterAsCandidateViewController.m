//
//  ENRegisterAsCandidateViewController.m
//  ElectionNigeria
//
//  Created by Vikas Kumar on 15/08/14.
//  Copyright (c) 2014 Vikas Kumar. All rights reserved.
//

#import "ENRegisterAsCandidateViewController.h"

#define SPACING 20

typedef enum
{
    kMale = 121,
    kFemale
}gender;

@interface ENRegisterAsCandidateViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverControllerDelegate>
{
    BOOL isKeyboardVisible;
    BOOL isFemale;
    NSDate * date;
    BOOL isProfileImageChanged;
    BOOL isUploadedToAmazon;
    NSArray * preferredCategories;
    NSString *imageName;
    UIPopoverController * popoverController;
}

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailIDtextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *localGovernmentTextFiled;
@property (weak, nonatomic) IBOutlet UITextField *stateTextField;
@property (weak, nonatomic) IBOutlet UITextField *townTextField;
@property (weak, nonatomic) IBOutlet UITextField *dobTextField;
@property (weak, nonatomic) IBOutlet UIImageView *maleCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *maleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *femaleCheckBox;
@property (weak, nonatomic) IBOutlet UILabel *femaleLabel;
@property (weak, nonatomic) IBOutlet UIView *pickerView;
@property (weak, nonatomic) IBOutlet UIButton *cancelDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *doneDatePicker;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)resetDatePicker:(id)sender;
- (IBAction)setDateOfBirth:(id)sender;

@end

@implementation ENRegisterAsCandidateViewController

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
    
    isProfileImageChanged = NO;
    isUploadedToAmazon = NO;
    [self initialSetUp];
    
    [self setUpViewController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)initialSetUp
{
    [self.cancelDatePicker setTitle:NSLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
    [self.doneDatePicker setTitle:NSLocalizedString(@"Done", nil) forState:UIControlStateNormal];
    
    [self.nameTextField setPlaceholder:NSLocalizedString(@"First_Name", nil)];
    [self.emailIDtextField setPlaceholder:NSLocalizedString(@"email ID", nil)];
    [self.lastNameTextField setPlaceholder:NSLocalizedString(@"Last_Name", nil)];
    
    [self.dobTextField setPlaceholder:NSLocalizedString(@"DOB", nil)];
    
    [self.maleLabel setText:NSLocalizedString(@"Male",nil)];
    [self.femaleLabel setText:NSLocalizedString(@"Female",nil)];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profilePictureTapped:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    _profilePicture.userInteractionEnabled = YES;
    [_profilePicture addGestureRecognizer:singleTap];
    
    _profilePicture.layer.borderColor = [UIColor blackColor].CGColor;
    _profilePicture.layer.masksToBounds = YES;
    _profilePicture.layer.borderWidth = 1.0f;
    
    _datePicker.maximumDate = [NSDate date];
    
}

- (IBAction)profilePictureTapped:(UITapGestureRecognizer *)sender
{
    [self tappedOutsideTextField:sender];
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:NSLocalizedString(@"Cancel", nil)
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:NSLocalizedString(@"Take_Photo", nil), NSLocalizedString(@"Choose_Photo", nil), nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    if (isIpad())
    {
        [actionSheet showFromRect:sender.view.frame inView:self.view animated:YES];
    }
    else
    {
        [actionSheet showInView:self.view];
    }
    
}

- (void) presentImagePickerOfSourceType:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
    imagePickerController.allowsEditing = NO;
    [self presentViewController:imagePickerController animated:YES completion:nil];
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
    [self.scrollView setContentSize:CGSizeMake(_scrollView.frame.size.width, _submitButton.frame.origin.y + CGRectGetHeight( _submitButton.frame) + SPACING)];
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
            frame.size.height = frame.size.height - keyboardFrameBeginRect.size.width + CGRectGetHeight(self.tabBarController.tabBar.frame);
            _scrollView.frame = frame;
        }
        else
        {
            CGRect frame = _scrollView.frame;
            frame.size.height = CGRectGetHeight(frame) - CGRectGetHeight(keyboardFrameBeginRect) + CGRectGetHeight(self.tabBarController.tabBar.frame) ;
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
            frame.size.height = frame.size.height + keyboardFrameBeginRect.size.width - CGRectGetHeight(self.tabBarController.tabBar.frame);
            _scrollView.frame = frame;
        }
        else
        {
            CGRect frame = _scrollView.frame;
            frame.size.height = CGRectGetHeight(frame) + CGRectGetHeight(keyboardFrameBeginRect) - CGRectGetHeight(self.tabBarController.tabBar.frame) ;
            _scrollView.frame = frame;
        }
    }
    
}

- (IBAction)done:(id)sender
{
    [self tappedOutsideTextField:nil];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tappedOutsideTextField:(id)sender
{
    [self.nameTextField resignFirstResponder];
    [self.addressTextField resignFirstResponder];
    [self.emailIDtextField resignFirstResponder];
    [self.lastNameTextField resignFirstResponder];
    [self.localGovernmentTextFiled resignFirstResponder];
    [self.townTextField resignFirstResponder];
    [self.stateTextField resignFirstResponder];
    [self.dobTextField resignFirstResponder];
    //    [self.passwordTextField resignFirstResponder];
}

- (IBAction)tappedOnCheckBox:(UITapGestureRecognizer*)sender
{
    if ([sender.view tag] == kMale)
    {
        [_maleCheckBox setImage:[UIImage imageNamed:@"checked_icon"]];
        [_femaleCheckBox setImage:[UIImage imageNamed:@"unchecked_icon"]];
        isFemale = NO;
    }
    else if ([sender.view tag] == kFemale)
    {
        [_femaleCheckBox setImage:[UIImage imageNamed:@"checked_icon"]];
        [_maleCheckBox setImage:[UIImage imageNamed:@"unchecked_icon"]];
        isFemale = YES;
    }
}

#pragma mark - UITextFieldDelegates -

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frameToScroll = textField.frame;
    frameToScroll.origin.y += 100;
    [self.scrollView scrollRectToVisible:frameToScroll animated:YES];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([textField isEqual:_dobTextField])
    {
        [self slideIn];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if([textField isEqual:_nameTextField])
    {
        [_lastNameTextField becomeFirstResponder];
    }
    else if([textField isEqual:_lastNameTextField])
    {
        [_emailIDtextField becomeFirstResponder];
    }
    else if([textField isEqual:_emailIDtextField])
    {
        [_dobTextField becomeFirstResponder];
    }
    else if([textField isEqual:_addressTextField])
    {
        [_localGovernmentTextFiled becomeFirstResponder];
    }
    else if([textField isEqual:_localGovernmentTextFiled])
    {
        [_stateTextField becomeFirstResponder];
    }
    else if([textField isEqual:_stateTextField])
    {
        [_townTextField becomeFirstResponder];
    }
    else if([textField isEqual:_dobTextField])
    {
        return NO;
    }
    return YES;
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        _profilePicture.image = image;
        isProfileImageChanged = YES;
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark DatePicker

- (void) slideIn
{
    [self tappedOutsideTextField:nil];
    
    if (isIpad())
    {
        UIViewController* popoverContent = [[UIViewController alloc] init];
        UIView *popoverView = [[UIView alloc] init];
        popoverView.backgroundColor = [UIColor whiteColor];
        [_datePicker setFrame:CGRectMake(0, 44, 360, 216)];
        [popoverView addSubview:_datePicker];
        
        popoverContent.view = popoverView;
        popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
        popoverController.delegate=self;
        
        [popoverController setPopoverContentSize:CGSizeMake(320, 264) animated:NO];
        [popoverController presentPopoverFromRect:_dobTextField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        [_pickerView setHidden:NO];
        [_datePicker setBackgroundColor:[UIColor whiteColor]];
        [_datePicker setAlpha:1.0];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self setDateOfBirth:self];
}

- (IBAction)resetDatePicker:(id)sender
{
    [_pickerView setHidden:YES];
}
- (IBAction)setDateOfBirth:(id)sender
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"dd-MMM-yyyy";
    [self.dobTextField setText:[dateFormatter stringFromDate:[_datePicker date]]];
    
    [_pickerView setHidden:YES];
}

@end
