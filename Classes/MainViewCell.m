#import "MainViewCell.h"

@implementation MainViewCell

@synthesize origin, destination, originLocality, destinationLocality, prompt, promptMode;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier]) {
        // Initialize the labels, their fonts, colors, alignment, and background color.
        origin = [[UILabel alloc] initWithFrame:CGRectZero];
        origin.font = [UIFont boldSystemFontOfSize:14];
        origin.backgroundColor = [UIColor clearColor];
		
        originLocality = [[UILabel alloc] initWithFrame:CGRectZero];
        originLocality.font = [UIFont systemFontOfSize:12];
		originLocality.textColor = [UIColor lightGrayColor];
        originLocality.backgroundColor = [UIColor clearColor];
		
        destination = [[UILabel alloc] initWithFrame:CGRectZero];
        destination.font = [UIFont boldSystemFontOfSize:14];
        destination.backgroundColor = [UIColor clearColor];
        
        destinationLocality = [[UILabel alloc] initWithFrame:CGRectZero];
        destinationLocality.font = [UIFont systemFontOfSize:12];
		destinationLocality.textColor = [UIColor lightGrayColor];
        destinationLocality.backgroundColor = [UIColor clearColor];
		
		prompt = [[UILabel alloc] initWithFrame:CGRectZero];
        prompt.font = [UIFont boldSystemFontOfSize:12];
        prompt.textColor = [UIColor darkGrayColor];
        prompt.backgroundColor = [UIColor clearColor];
        
        // Add the labels to the content view of the cell.
        
        // Important: although UITableViewCell inherits from UIView, you should add subviews to its content view
        // rather than directly to the cell so that they will be positioned appropriately as the cell transitions 
        // into and out of editing mode.
        
        [self.contentView addSubview:origin];
		[self.contentView addSubview:originLocality];
        [self.contentView addSubview:destination];
		[self.contentView addSubview:destinationLocality];
        [self.contentView addSubview:prompt];
    }
    return self;
}

- (void)dealloc {
    [origin release];
    [destination release];
    [originLocality release];
    [destinationLocality release];
    [prompt release];
    [super dealloc];
}

// Setting the prompt mode to YES hides the type/name labels and shows the prompt label.
- (void)setPromptMode:(BOOL)flag {
    if (flag) {
        origin.hidden = YES;
        destination.hidden = YES;
        originLocality.hidden = YES;
        destinationLocality.hidden = YES;
        prompt.hidden = NO;
    } else {
        origin.hidden = NO;
        destination.hidden = NO;
        originLocality.hidden = NO;
        destinationLocality.hidden = NO;
        prompt.hidden = YES;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // Start with a rect that is inset from the content view by 5 pixels on all sides.
    CGRect baseRect = CGRectInset(self.contentView.bounds, 5, 5);
    CGRect rect = baseRect;
    //rect.origin.x += 10;
	//rect.size.width = baseRect.size.width - 10;
    rect.origin.x += 10;
	rect.size.width = baseRect.size.width - 20;

    prompt.frame = rect;

	rect.origin.x += 0;
	rect.origin.y -= 25;
    origin.frame = rect;

	rect.origin.x += 15;
	rect.origin.y += 16;
    originLocality.frame = rect;

	rect.origin.x -= 15;
	rect.origin.y += 18;
    destination.frame = rect;	

	rect.origin.x += 15;
	rect.origin.y += 16;
    destinationLocality.frame = rect;	
}

// Update the text color of each label when entering and exiting selected mode.
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        origin.textColor = [UIColor whiteColor];
        destination.textColor = [UIColor whiteColor];
        originLocality.textColor = [UIColor whiteColor];
        destinationLocality.textColor = [UIColor whiteColor];
        prompt.textColor = [UIColor whiteColor];
    } else {
        origin.textColor = [UIColor blackColor];
        destination.textColor = [UIColor blackColor];
        originLocality.textColor = [UIColor blackColor];
        destinationLocality.textColor = [UIColor blackColor];
        prompt.textColor = [UIColor darkGrayColor];
    }
}

@end
