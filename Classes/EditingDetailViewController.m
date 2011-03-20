#import "EditingDetailViewController.h"
#import "../JSON/JSON.h"
#import "EditingDetailViewCell.h"

@implementation EditingDetailViewController

@synthesize tableView, mySearchBar, editingItem, myTitle;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    if (self = [super initWithNibName:nibName bundle:bundle]) {
		// Initialization code
    }
	tableSections = [[NSMutableArray alloc] initWithCapacity:4];
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[tableSections release];
    [myTitle release];
    [editingItem release];
	mySearchBar.delegate = nil;
	[mySearchBar release];
	tableView.delegate = nil;
	tableView.dataSource = nil;
    [tableView release];
    [super dealloc];
}

- (void)viewWillDisappear:(BOOL)animated {
	[mySearchBar resignFirstResponder];	
}

- (void)viewWillAppear:(BOOL)animated {
	[self emptyTable];
    [tableView reloadData];
	self.title = myTitle;
	mySearchBar.text = @"";
	mySearchBar.autocorrectionType = UITextAutocorrectionTypeNo;
	mySearchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
	[mySearchBar becomeFirstResponder];
}

- (NSIndexPath *)tableView:(UITableView *)aTableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *value = [[tableSections objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row + 1)];
    [editingItem setValue:value forKey:myTitle];
    [self.navigationController popViewControllerAnimated:YES];
    return indexPath;
}

// The table uses standard UITableViewCells. The text for a cell is simply the string value of the matching type.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"EditingDetailViewCell";
	
	EditingDetailViewCell *cell = (EditingDetailViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[EditingDetailViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	
	NSString *text = [[tableSections objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row + 1)];
	NSRange range1 = [text rangeOfString:@"("];
	NSRange range2 = [text rangeOfString:@")"];
	NSRange range3;
	range3.location = range1.location + 1;
	range3.length = range2.location - range1.location - 1;

	cell.firstText = [text substringToIndex:range1.location];
	cell.lastText = [text substringWithRange:range3];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [[tableSections objectAtIndex:section] count] - 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [tableSections count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [[tableSections objectAtIndex:section] objectAtIndex:0];
}

- (void)emptyTable {
	[tableSections removeAllObjects];
	[tableSections addObject:[NSArray arrayWithObjects:@"", nil]];
	
	// The first member of the array is the title. Thus, [array count] MUST BE >= 1.
	//[tableSections addObject:[NSArray arrayWithObjects:@"Train Stations", @"Train1", @"Train2", nil]];
	//[tableSections addObject:[NSArray arrayWithObjects:@"Tram Stops", @"Tram1", @"Tram2", nil]];
	//[tableSections addObject:[NSArray arrayWithObjects:@"Bus Stops", @"Bus1", @"Bus2", nil]];	
	//Check for validity of data, if not valid, return this:
	//[tableSections addObject:[NSArray arrayWithObjects:@"", nil]];
}

- (void)getData:(NSString *)searchTerm; {
	[tableSections removeAllObjects];
	
	NSURL *url = [NSURL URLWithString:@"http://1.latest.melb-journey.appspot.com/searchLocations"];
	NSMutableString *requestString = [NSMutableString stringWithString:@"query="];
	[requestString appendString:searchTerm];
	
	NSData *requestData = [NSData dataWithBytes:[requestString UTF8String]
										 length:[requestString length]];
	
	NSMutableURLRequest *netRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	[netRequest setHTTPMethod:@"POST"];
	[netRequest setHTTPBody:requestData];
	[netRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

	BOOL canHandleRequest = [NSURLConnection canHandleRequest:netRequest];
	
	if (!canHandleRequest) {
		[tableSections addObject:[NSArray arrayWithObjects:@"", nil]];
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Melb Journey Error"
														message:@"No Internet connection."
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		mySearchBar.text = @"";
		[netRequest release];
		return;
	}
	
	
	
	NSMutableString *errorMessage = [NSMutableString stringWithCapacity:10];
	NSHTTPURLResponse *netResponse;
	NSError *netError;
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	NSData *rawNetData = [NSURLConnection sendSynchronousRequest:netRequest 
											returningResponse:&netResponse error:&netError];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	[netRequest release];
	
	if ([netResponse statusCode] == 200) {
		NSString *json = [[NSString alloc] initWithData:rawNetData 
											   encoding:NSUTF8StringEncoding];
		NSMutableArray *netData = [json JSONValue];
		[json autorelease];
		
		if (netData != nil) {
			NSString *worqStatus = [[netData objectAtIndex:0] valueForKey:@"status"];
			NSString *worqMessage = [[netData objectAtIndex:0] valueForKey:@"message"];
			
			if ([worqStatus isEqualToString:@"WORQ-OK"] && [worqMessage isEqualToString:@"SL-OK"]) {
				int count = [netData count];
				int index;
				for (index = 1; index < count; index++) {
					NSDictionary *section = [netData objectAtIndex:index];
					NSString *transportType = [section objectForKey:@"transportType"];
					NSArray *transportLocations = [section objectForKey:@"transportLocations"];
					
					NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:10];
					[tempArray addObject:transportType];
					[tempArray addObjectsFromArray:transportLocations];
					[tableSections addObject:[NSArray arrayWithArray:tempArray]];
					[tempArray release];
				}
				return;
			} else if ([worqStatus isEqualToString:@"WORQ-OK"] && [worqMessage isEqualToString:@"SL-NOTFOUND"]) {
				[errorMessage setString:@"Cannot find the location."];
			} else {
				//[errorMessage setString:worqStatus];
				[errorMessage setString:@"Server Error: "];
				[errorMessage appendString:worqMessage];
			}
		} else {
			[errorMessage setString:@"Invalid data from server."];
		}
	} else {
		[errorMessage setString:@"Invalid connection. Try again later."];
	}
			
	[tableSections addObject:[NSArray arrayWithObjects:@"", nil]];
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Melb Journey Error"
													message:errorMessage
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	mySearchBar.text = @"";
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[searchBar resignFirstResponder];
	[self getData:[searchBar text]];
	[tableView reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
	[self emptyTable];
	[tableView reloadData];
}

@end