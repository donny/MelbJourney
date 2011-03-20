//
//  InfoViewController.m
//  Melb Journey
//
//  Created by Donny Kurniawan on 12/02/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "InfoViewController.h"


@implementation InfoViewController

@synthesize textView;

/*
// The designated initializer. Override to perform setup that is required before the view is loaded.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSMutableString *text = [NSMutableString stringWithCapacity:100];
	[text appendString:@"The application shows the next few travel plans for a given journey in Melbourne or Victoria (Australia). "];
	[text appendString:@"The application uses the data provided by Metlink Melbourne. "];
	[text appendString:@"However, Melbourne Journey is in no way associated with Metlink Melbourne.\n"];
	[text appendString:@"For application feedback and support: "];
	
	self.textView.text = text;
	self.view.backgroundColor = [UIColor viewFlipsideBackgroundColor];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[textView release];
    [super dealloc];
}

- (IBAction)done:(id)sender {
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)emailAction:(id)sender {
	NSURL *actionURL = [NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@?subject=%@&body=%@",
											 @"info+melbjourney@worqbench.com", @"Melbourne%20Journey%20Feedback%20or%20Support", @"..."]];
	[[UIApplication sharedApplication] openURL:actionURL];
}

- (IBAction)webAction:(id)sender {
	NSURL *actionURL = [NSURL URLWithString:@"http://www.worqbench.com/"];
	[[UIApplication sharedApplication] openURL:actionURL];
}

@end
