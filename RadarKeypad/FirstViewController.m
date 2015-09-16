#import "FirstViewController.h"
#import "LastViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Fix"]) {
        [segue.destinationViewController setShouldApplyFix:YES];
    }
}

@end
