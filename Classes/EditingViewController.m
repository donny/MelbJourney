#import "EditingViewController.h"
#import "EditingDetailViewController.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation EditingViewController

@synthesize editingContent, editingItem, editingItemCopy, tableView, saveButton, cancelButton, editingDetailViewController;

// When we set the editing item, we also make a copy in case edits are made and then canceled - then we can
// restore from the copy.
- (void)setEditingItem:(NSMutableDictionary *)anItem {
    [editingItem release];
    editingItem = [anItem retain];
    self.editingItemCopy = editingItem;
}

- (void)dealloc {
	[saveButton release];
	[cancelButton release];
	[originCell release];
	[destinationCell release];
	[originHeader release];
	[destinationHeader release];

    [editingContent release];
    [editingItem release];
    [editingItemCopy release];
	tableView.delegate = nil;
	tableView.dataSource = nil;
    [tableView release];
    [editingDetailViewController release];
    [super dealloc];
}

- (IBAction)cancel:(id)sender {
    // cancel edits, restore all values from the copy
    newItem = NO;
    [editingItem setValuesForKeysWithDictionary:editingItemCopy];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)save:(id)sender {
    // save edits to the editing item and add new item to the content.
    [editingItem setValue:originCell.textLabel.text forKey:@"Origin"];
    [editingItem setValue:destinationCell.textLabel.text forKey:@"Destination"];
    if (newItem) {
        [editingContent addObject:editingItem];
        newItem = NO;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	if (saveButton == nil) {
		self.saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave 
																		target:self action:@selector(save:)];
		self.navigationItem.rightBarButtonItem = saveButton;
	}
	
	if (cancelButton == nil) {
		self.cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel 
																		target:self action:@selector(cancel:)];
		self.navigationItem.leftBarButtonItem = cancelButton;
	}	
}

- (void)viewWillAppear:(BOOL)animated {
    self.title = @"Journey";
	self.view.backgroundColor = [UIColor clearColor];
	
    // If the editing item is nil, that indicates a new item should be created
    if (editingItem == nil) {
        self.editingItem = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"Origin", @"", @"Destination", nil];
        // rather than immediately add the new item to the content array, set a flag. When the user saves, add the 
        // item then; if the user cancels, no action is needed.
        newItem = YES;
    }
    
	if (!originCell) {
        originCell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"OriginCell"];
		originCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    originCell.textLabel.text = [editingItem valueForKey:@"Origin"];

	if (!destinationCell) {
        destinationCell = [[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"DestinationCell"];
		destinationCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    destinationCell.textLabel.text = [editingItem valueForKey:@"Destination"];
	
	if (!originHeader) {
		originHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 280, 50)];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.font = [UIFont boldSystemFontOfSize:17];
		headerLabel.textColor = UIColorFromRGB(0xFFCC00);
		headerLabel.text = @"Origin";
		
		UIImageView *headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(18, 12, 16, 26)];
		headerImage.image = [UIImage imageNamed:@"hOriginImage.png"];
		
		[originHeader addSubview:headerLabel];
		[originHeader addSubview:headerImage];
		[headerLabel release];
		[headerImage release];
	}
	
	if (!destinationHeader) {
		destinationHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, 280, 50)];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.font = [UIFont boldSystemFontOfSize:17];
		headerLabel.textColor = UIColorFromRGB(0xFFCC00);
		headerLabel.text = @"Destination";
		
		UIImageView *headerImage = [[UIImageView alloc] initWithFrame:CGRectMake(18, 12, 16, 26)];
		headerImage.image = [UIImage imageNamed:@"hDestinationImage.png"];
				
		[destinationHeader addSubview:headerLabel];
		[destinationHeader addSubview:headerImage];
		[headerLabel release];
		[headerImage release];
	}	
	
    [tableView reloadData];
	
	if ([originCell.textLabel.text length] == 0 || [destinationCell.textLabel.text length] == 0) {
		saveButton.enabled = FALSE;
	} else{
		saveButton.enabled = TRUE;
	}
}

- (NSIndexPath *)tableView:(UITableView *)aTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!editingDetailViewController) {
		EditingDetailViewController *controller = [[EditingDetailViewController alloc] initWithNibName:@"EditingDetailView" bundle:nil];
		self.editingDetailViewController = controller;
		[controller release];
	}

	editingDetailViewController.editingItem = editingItem;
	
	if (indexPath.section == 0)
		editingDetailViewController.myTitle = @"Origin";
	else
		editingDetailViewController.myTitle = @"Destination";
	
	[self.navigationController pushViewController:editingDetailViewController animated:YES];

    return indexPath;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	return (section == 0) ? @"Origin" : @"Destination";
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
}

- (UIView *)tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (section == 0) ? originHeader : destinationHeader;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 0) ? originCell : destinationCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)aTableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

@end
