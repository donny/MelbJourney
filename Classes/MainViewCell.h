#import <UIKit/UIKit.h>

@interface MainViewCell : UITableViewCell {
    UITextField *origin;
    UITextField *destination;
    UITextField *originLocality;
    UITextField *destinationLocality;
    UITextField *prompt;
    BOOL promptMode;
}

@property (readonly, retain) UITextField *origin;
@property (readonly, retain) UITextField *destination;
@property (readonly, retain) UITextField *originLocality;
@property (readonly, retain) UITextField *destinationLocality;
@property (readonly, retain) UITextField *prompt;
@property BOOL promptMode;

@end
