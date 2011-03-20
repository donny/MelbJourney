#import "JourneyViewController.h"
#import "JourneyDetailViewController.h"
#import "../JSON/JSON.h"
#import "JourneyViewCell.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation JourneyViewController

@synthesize tableView, originLoc, destinationLoc, journeyDetailViewController;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    if (self = [super initWithNibName:nibName bundle:bundle]) {
		// Initialization code
    }
	tableSections = [[NSMutableArray alloc] initWithCapacity:1];

	CGRect newFrame = CGRectMake(0.0, 0.0, 320.0, 40.0);
	footerLabel = [[UILabel alloc] initWithFrame:newFrame];
	footerLabel.textAlignment = UITextAlignmentCenter;
	footerLabel.backgroundColor = [UIColor clearColor];
	
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[journeyDetailViewController release];
	[tableSections release];
	[footerLabel release];
	[headerView release];
    [originLoc release];
	[destinationLoc release];
	tableView.delegate = nil;
	tableView.dataSource = nil;
    [tableView release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
	headerView.hidden = NO;
	footerLabel.hidden = YES;
	
	[self getData];
	footerLabel.text = @"";
	[tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = @"Journey";
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor clearColor];
	
	if (!headerView) {
		headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
		
		UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, 280, 50)];
		headerLabel.backgroundColor = [UIColor clearColor];
		headerLabel.font = [UIFont boldSystemFontOfSize:17];
		headerLabel.textColor = UIColorFromRGB(0xFFCC00);
		headerLabel.text = @"Depart          Arrive          Duration";
		
		[headerView addSubview:headerLabel];
		
		[headerLabel release];
	}	
	
	headerView.hidden = YES;
	footerLabel.hidden = NO;
	
	[self emptyTable];
    [tableView reloadData];
	tableView.tableFooterView = footerLabel;
	footerLabel.text = @"Fetching data...";
	footerLabel.textColor = UIColorFromRGB(0xFFCC00);
}

- (JourneyDetailViewController *)journeyDetailViewController {
    // Instantiate the journey detail view controller if necessary.
    if (journeyDetailViewController == nil) {
        JourneyDetailViewController *controller = [[JourneyDetailViewController alloc] initWithNibName:@"JourneyDetailView" bundle:nil];
        self.journeyDetailViewController = controller;
        [controller release];
    }
    return journeyDetailViewController;
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	JourneyDetailViewController *controller = self.journeyDetailViewController;
	NSDictionary *dict = [[tableSections objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row + 1)];
	controller.journeySessionID = [dict objectForKey:@"journeySessionID"];
	controller.journeySelection = [NSString stringWithFormat:@"%d", (indexPath.row + 1)];
	[self.navigationController pushViewController:controller animated:YES];
}

// The table uses standard UITableViewCells. The text for a cell is simply the string value of the matching type.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 	static NSString *CellIdentifier = @"JourneyViewCell";
	
	JourneyViewCell *cell = (JourneyViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[JourneyViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	
	NSDictionary *dict = [[tableSections objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row + 1)];
	
	cell.firstText = [dict objectForKey:@"journeyDepart"];
	cell.secondText = [dict objectForKey:@"journeyArrive"];
	cell.lastText = [dict objectForKey:@"journeyDuration"];
	
	return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section {
	return [[tableSections objectAtIndex:section] count] - 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [tableSections count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	return [[tableSections objectAtIndex:section] objectAtIndex:0];
//}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 50;
}

- (UIView *)tableView: (UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return headerView;
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

- (void)getData {
	[tableSections removeAllObjects];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"d#yyyyMM#h#m#a"];
	NSDate *now = [NSDate date];
	NSString *requestDateTime = [dateFormatter stringFromDate:now];
	[dateFormatter release];
	
	NSURL *url = [NSURL URLWithString:@"http://1.latest.melb-journey.appspot.com/listJourneys"];
	NSMutableString *requestString = [NSMutableString stringWithString:@"dateTime="];
	[requestString appendString:requestDateTime];
	[requestString appendString:@"&nameOrigin="];
	[requestString appendString:originLoc];
	[requestString appendString:@"&nameDestination="];
	[requestString appendString:destinationLoc];
	
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
			
			if ([worqStatus isEqualToString:@"WORQ-OK"] && [worqMessage isEqualToString:@"LJ-OK"]) {
				int count = [netData count];
				int index;
				
				NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:10];

				//[resultArray addObject:@"Journey Summaries"];
				[resultArray addObject:@" "];

				for (index = 1; index < count; index++) {
					NSDictionary *section = [netData objectAtIndex:index];
					[resultArray addObject:section];
				}
				
				[tableSections addObject:[NSArray arrayWithArray:resultArray]];
				[resultArray release];
				return;
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
}

@end
