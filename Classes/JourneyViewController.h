#import <UIKit/UIKit.h>

@class JourneyDetailViewController;

@interface JourneyViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *tableView;
	NSString *originLoc;
	NSString *destinationLoc;
	NSMutableArray *tableSections;
	JourneyDetailViewController *journeyDetailViewController;
	UILabel *footerLabel;
	UIView *headerView;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *originLoc;
@property (nonatomic, copy) NSString *destinationLoc;
@property (nonatomic, retain) JourneyDetailViewController *journeyDetailViewController;

- (void)getData;
- (void)emptyTable;

@end