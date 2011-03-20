#import <UIKit/UIKit.h>

@interface JourneyDetailViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
    UITableView *tableView;
	NSMutableArray *tableSections;
	NSString *journeySessionID;
	NSString *journeySelection;
	UILabel *footerLabel;
	NSMutableString *stopID;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, copy) NSString *journeySessionID;
@property (nonatomic, copy) NSString *journeySelection;

- (void)getData;
- (void)emptyTable;
- (NSString *)getMap;

@end