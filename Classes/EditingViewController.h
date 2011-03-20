#import <UIKit/UIKit.h>

@class EditingDetailViewController;

@interface EditingViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *editingContent;
    NSMutableDictionary *editingItem;
    NSDictionary *editingItemCopy;
    BOOL newItem;
	
    UITableView *tableView;
	UIBarButtonItem *saveButton;
	UIBarButtonItem *cancelButton;
    
	UITableViewCell *originCell;
	UITableViewCell *destinationCell;
	UIView *originHeader;
	UIView *destinationHeader;

    EditingDetailViewController *editingDetailViewController;
}

@property (nonatomic, retain) NSMutableArray *editingContent;
@property (nonatomic, retain) NSMutableDictionary *editingItem;
@property (nonatomic, copy) NSDictionary *editingItemCopy;

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *cancelButton;
@property (nonatomic, retain) EditingDetailViewController *editingDetailViewController;

- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
    
@end