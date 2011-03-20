#import <UIKit/UIKit.h>

@interface EditingDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tableView;
	UISearchBar *mySearchBar;
	NSMutableDictionary *editingItem;
	NSString *myTitle;
	NSMutableArray *tableSections;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) IBOutlet UISearchBar *mySearchBar;
@property (nonatomic, retain) NSMutableDictionary *editingItem;
@property (nonatomic, copy) NSString *myTitle;

- (void)getData:(NSString *)searchTerm;
- (void)emptyTable;

@end