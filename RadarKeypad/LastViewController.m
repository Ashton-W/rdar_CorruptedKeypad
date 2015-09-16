#import "LastViewController.h"

@interface LastViewController () <UIAlertViewDelegate, UITextFieldDelegate>

@property (nonatomic) UIAlertView *alertView;
@property (nonatomic) BOOL keyboardHidden;
@property (nonatomic) IBOutlet UITextField *textField;

@property (nonatomic, copy) void (^operation)(void);

@end

@implementation LastViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.shouldApplyFix ? @"Fix" : @"Bug";
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self observeKeyboard];
    
    self.textField.text = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)observeKeyboard
{
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
}

- (void)reenter
{
    UIViewController *initialViewController = [self.storyboard instantiateInitialViewController];
    
    [UIApplication sharedApplication].keyWindow.rootViewController = initialViewController;
    
    self.textField.text = nil;
}

#pragma mark <UITextFieldDelegate>

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = textField.text;
    newString = [newString stringByReplacingCharactersInRange:range withString:string];
    
    if (newString.length >= 4) {
        [textField resignFirstResponder];
        
        self.alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"error" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        
        if (self.shouldApplyFix) {
            [self showAlertWithFix];
        }
        else {
            [self showAlert];
        }
    }
    
    return YES;
}

- (void)showAlert
{
    [self.alertView show];
}

- (void)showAlertWithFix
{
    // adding a short dispatch_after delay would work too, but I think it
    // is tied to the keyboard animation
    
    if (self.keyboardHidden) {
        [self.alertView show];
    }
    else {
        __block UIAlertView *alert = self.alertView;
        self.operation = ^{
            [alert show];
        };
    }
}

#pragma mark <UIAlertViewDelegate>

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self reenter];
}

#pragma mark Notifications

- (void)keyboardDidHide:(NSNotification *)notification
{
    self.keyboardHidden = YES;
    if (self.operation) {
        self.operation();
        self.operation = NULL;
    }
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    self.keyboardHidden = NO;
}

@end
