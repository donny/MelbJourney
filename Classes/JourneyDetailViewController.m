#import "JourneyDetailViewController.h"
#import "../JSON/JSON.h"

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation JourneyDetailViewController

@synthesize tableView, journeySessionID, journeySelection;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle {
    if (self = [super initWithNibName:nibName bundle:bundle]) {
		// Initialization code
    }
	tableSections = [[NSMutableArray alloc] initWithCapacity:1];
	stopID = [[NSMutableString alloc] initWithCapacity:10];
	
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
	[tableSections release];
	[stopID release];
	[footerLabel release];
	[journeySessionID release];
	[journeySelection release];

	tableView.delegate = nil;
	tableView.dataSource = nil;
    [tableView release];
    [super dealloc];
}

- (void)viewDidAppear:(BOOL)animated {
	footerLabel.hidden = YES;
	
	[self getData];
	footerLabel.text = @"";
	[tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	self.title = @"Details";
	self.tableView.backgroundColor = [UIColor clearColor];
	self.view.backgroundColor = [UIColor clearColor];
	
	footerLabel.hidden = NO;
	
	[self emptyTable];
    [tableView reloadData];
	tableView.tableFooterView = footerLabel;
	footerLabel.text = @"Fetching data...";
	footerLabel.textColor = UIColorFromRGB(0xFFCC00);
}

- (void)tableView:(UITableView *)aTableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
//- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[aTableView deselectRowAtIndexPath:indexPath animated:NO];
	
	NSString *text = [[tableSections objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row + 1)];
	NSRange range = [text rangeOfString:@"#"];
	NSString *detailsPrefix = [text substringToIndex:range.location];
	
	if (![detailsPrefix hasPrefix:@"MAP"])
		return;
	
	NSString *mapString = [detailsPrefix substringFromIndex:4];
	[stopID setString:mapString];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Stop ID: %@", mapString]
															 delegate:self cancelButtonTitle:@"Cancel" 
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Open Web Info", @"Display Map", nil];
	actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
	[actionSheet showInView:self.view]; // show from our table view (pops up in the middle of the table)
	[actionSheet release];
}

// The table uses standard UITableViewCells. The text for a cell is simply the string value of the matching type.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"JourneyDetailViewCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		
		CGRect baseRect = CGRectInset(cell.contentView.bounds, 5, 5);
		CGRect rect = baseRect;
		rect.origin.x += 0;
		rect.size.width = baseRect.size.width - 45;
		
		UILabel *label = [[UILabel alloc] initWithFrame:rect];
		label.numberOfLines = 2;
		label.font = [UIFont systemFontOfSize:12];
		label.textColor = [UIColor blackColor];
		label.tag = 1;
		
		//NOT [cell addSubview:label];
		[cell.contentView addSubview:label];
		[label release];
    }
	
	UILabel *label = (UILabel*)[cell viewWithTag:1];
	NSString *text = [[tableSections objectAtIndex:indexPath.section] objectAtIndex:(indexPath.row + 1)];

	NSRange range = [text rangeOfString:@"#"];
	
	NSString *detailsPrefix = [text substringToIndex:range.location];
	NSString *detailsText = [text substringFromIndex:(range.location + 1)];
	
	// TODO: Need to change the accessory type (read the email from Apple).
	
    if ([text hasPrefix:@"MAP"])
		cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
	else
		cell.accessoryType = UITableViewCellAccessoryNone;
	
	if ([detailsPrefix isEqualToString:@"HEAD"])
		label.font = [UIFont boldSystemFontOfSize:12];
	else
		label.font = [UIFont systemFontOfSize:12];
	
/*	if ([detailsPrefix hasPrefix:@"MAP"])
		label.textColor = [UIColor blueColor];
	else
		label.textColor = [UIColor blackColor];
*/	
	label.text = detailsText;
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

- (void)getData {
	NSURL *url = [NSURL URLWithString:@"http://1.latest.melb-journey.appspot.com/getDetails"];
	NSMutableString *requestString = [NSMutableString stringWithString:@"session="];
	[requestString appendString:journeySessionID];
	[requestString appendString:@"&selection="];
	[requestString appendString:journeySelection];
	
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
			
			if ([worqStatus isEqualToString:@"WORQ-OK"] && [worqMessage isEqualToString:@"GD-OK"]) {
				NSMutableArray *resultArray = [[NSMutableArray alloc] initWithCapacity:10];
				
				//[resultArray addObject:@"Journey Details"];
				[resultArray addObject:@" "];

				NSDictionary *details = [netData objectAtIndex:1];
				[resultArray addObjectsFromArray:[details objectForKey:@"details"]];
				
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

- (NSString *)getMap {
	NSURL *url = [NSURL URLWithString:@"http://1.latest.melb-journey.appspot.com/getStopInfo"];
	NSMutableString *requestString = [NSMutableString stringWithString:@"stop="];
	[requestString appendString:stopID];
	
	NSData *requestData = [NSData dataWithBytes:[requestString UTF8String]
										 length:[requestString length]];
	
	NSMutableURLRequest *netRequest = [[NSMutableURLRequest alloc] initWithURL:url];
	[netRequest setHTTPMethod:@"POST"];
	[netRequest setHTTPBody:requestData];
	[netRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
	
	BOOL canHandleRequest = [NSURLConnection canHandleRequest:netRequest];
	
	if (!canHandleRequest) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Melb Journey Error"
														message:@"No Internet connection."
													   delegate:nil 
											  cancelButtonTitle:@"OK" 
											  otherButtonTitles:nil];
		[alert show];
		[alert release];
		[netRequest release];
		return nil;
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
			
			if ([worqStatus isEqualToString:@"WORQ-OK"] && [worqMessage isEqualToString:@"GSI-OK"]) {
				NSDictionary *details = [netData objectAtIndex:1];
				NSString *address = [details objectForKey:@"address"];
				
				NSString *retVal = [[NSString alloc] initWithString:address];
				[retVal autorelease];
				return retVal;
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
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Melb Journey Error"
													message:errorMessage
												   delegate:nil 
										  cancelButtonTitle:@"OK" 
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
	return nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		NSURL *actionURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.metlinkmelbourne.com.au/stop/view/%@", 
												 stopID]];
		[[UIApplication sharedApplication] openURL:actionURL];
	} else if (buttonIndex == 1) {
		NSString *address = [self getMap];
		if (address) {
			NSURL *actionURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://maps.google.com/maps?q=%@", 
													 [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
			[[UIApplication sharedApplication] openURL:actionURL];
		}
	}
}

@end
