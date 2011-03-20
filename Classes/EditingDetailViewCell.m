//
//  FirstLastExampleTableViewCell.m
//  FastScrolling
//
//  Created by Loren Brichter on 12/9/08.
//  Copyright 2008 atebits. All rights reserved.
//  http://blog.atebits.com/2008/12/fast-scrolling-in-tweetie-with-uitableview/
//

#import "EditingDetailViewCell.h"

@implementation EditingDetailViewCell

@synthesize firstText;
@synthesize lastText;

static UIFont *firstTextFont = nil;
static UIFont *lastTextFont = nil;

+ (void)initialize
{
	if(self == [EditingDetailViewCell class])
	{
		firstTextFont = [[UIFont boldSystemFontOfSize:12] retain];
		lastTextFont = [[UIFont systemFontOfSize:12] retain];

		// Original code:
		//firstTextFont = [[UIFont boldSystemFontOfSize:12] retain];
		//lastTextFont = [[UIFont systemFontOfSize:12] retain];
		
		// this is a good spot to load any graphics you might be drawing in -drawContentView:
		// just load them and retain them here (ONLY if they're small enough that you don't care about them wasting memory)
		// the idea is to do as LITTLE work (e.g. allocations) in -drawContentView: as possible
	}
}

- (void)dealloc
{
	[firstText release];
	[lastText release];
    [super dealloc];
}

// the reason I don't synthesize setters for 'firstText' and 'lastText' is because I need to 
// call -setNeedsDisplay when they change

- (void)setFirstText:(NSString *)s
{
	[firstText release];
	firstText = [s copy];
	[self setNeedsDisplay]; 
}

- (void)setLastText:(NSString *)s
{
	[lastText release];
	lastText = [s copy];
	[self setNeedsDisplay]; 
}

- (void)drawContentView:(CGRect)r
{
	CGContextRef context = UIGraphicsGetCurrentContext();

	UIColor *backgroundColor = [UIColor whiteColor];
	UIColor *textColor = [UIColor blackColor];
	
	if(self.selected)
	{
		backgroundColor = [UIColor clearColor];
		textColor = [UIColor whiteColor];
	}
	
	[backgroundColor set];
	CGContextFillRect(context, r);
	
	CGPoint p;
	p.x = 10;
	p.y = 7;
	
	[textColor set];
	
	[firstText drawAtPoint:p forWidth:300 withFont:firstTextFont 
			 lineBreakMode:UILineBreakModeTailTruncation];
				
	textColor = [UIColor darkGrayColor];
	[textColor set];
	
	p.x += 10;
	p.y += 15;
	[lastText drawAtPoint:p withFont:lastTextFont];
}

@end
