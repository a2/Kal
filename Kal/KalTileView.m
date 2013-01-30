/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalDate.h"
#import "KalPrivate.h"
#import "KalTileView.h"

extern const CGSize KalGridViewTileSize;

@interface KalTileView ()

@property (nonatomic) CGPoint origin;

@end

@implementation KalTileView

- (BOOL) belongsToAdjacentMonth
{
	return self.type == KalTileViewTypeAdjacent;
}
- (BOOL) isToday
{
	return self.type == KalTileViewTypeToday;
}

- (id) initWithFrame: (CGRect) frame
{
	if ((self = [super initWithFrame: frame]))
	{
		self.accessibilityTraits = UIAccessibilityTraitButton;
		self.backgroundColor = [UIColor clearColor];
		self.clipsToBounds = NO;
		self.isAccessibilityElement = YES;
		self.opaque = NO;
		self.origin = frame.origin;
		
		[self resetState];
	}
	
	return self;
}

- (void) drawRect: (CGRect) rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGFloat fontSize = 24.f;
	UIFont *font = [UIFont boldSystemFontOfSize:fontSize];
	UIColor *shadowColor = nil;
	UIColor *textColor = nil;
	UIImage *markerImage = nil;
	CGContextSelectFont(ctx, [font.fontName cStringUsingEncoding:NSUTF8StringEncoding], fontSize, kCGEncodingMacRoman);

	CGContextTranslateCTM(ctx, 0, KalGridViewTileSize.height);
	CGContextScaleCTM(ctx, 1, -1);

	if (self.isToday)
	{
		NSString *imageName;
		if (self.selected)
			imageName = @"Kal.bundle/kal_tile_today_selected.png";
		else
			imageName = @"Kal.bundle/kal_tile_today.png";
		
		[[[UIImage imageNamed: imageName] resizableImageWithCapInsets: UIEdgeInsetsMake(0, 6, 0, 6)] drawInRect: CGRectMake(0, -1, KalGridViewTileSize.width + 1, KalGridViewTileSize.height + 1)];

		textColor = [UIColor whiteColor];
		shadowColor = [UIColor blackColor];
		markerImage = [UIImage imageNamed: @"Kal.bundle/kal_marker_today.png"];
	}
	else if (self.selected)
	{
		[[[UIImage imageNamed: @"Kal.bundle/kal_tile_selected.png"] resizableImageWithCapInsets: UIEdgeInsetsMake(0, 1, 0, 1)] drawInRect:CGRectMake(0, -1, KalGridViewTileSize.width+1, KalGridViewTileSize.height+1)];
		
		textColor = [UIColor whiteColor];
		shadowColor = [UIColor blackColor];
		markerImage = [UIImage imageNamed: @"Kal.bundle/kal_marker_selected.png"];
	}
	else if (self.belongsToAdjacentMonth)
	{
		textColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Kal.bundle/kal_tile_dim_text_fill.png"]];
		shadowColor = nil;
		markerImage = [UIImage imageNamed: @"Kal.bundle/kal_marker_dim.png"];
	}
	else
	{
		textColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Kal.bundle/kal_tile_text_fill.png"]];
		shadowColor = [UIColor whiteColor];
		markerImage = [UIImage imageNamed: @"Kal.bundle/kal_marker.png"];
	}

	if (self.marked)
		[markerImage drawInRect:CGRectMake(21.f, 5.f, 4.f, 5.f)];

	NSUInteger n = self.date.day;
	NSString *dayText = [NSString stringWithFormat: @"%lu", (unsigned long) n];
	const char *day = [dayText cStringUsingEncoding: NSUTF8StringEncoding];
	CGSize textSize = [dayText sizeWithFont: font];
	
	CGFloat textX = roundf(0.5f * (KalGridViewTileSize.width - textSize.width));
	CGFloat textY = 6.f + roundf(0.5f * (KalGridViewTileSize.height - textSize.height));
	if (shadowColor)
	{
		[shadowColor setFill];
		CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);
		textY += 1.f;
	}
	
	[textColor setFill];
	CGContextShowTextAtPoint(ctx, textX, textY, day, n >= 10 ? 2 : 1);

	if (self.highlighted)
	{
		[[UIColor colorWithWhite: 0.25f alpha: 0.3f] setFill];
		CGContextFillRect(ctx, CGRectMake(0, 0, KalGridViewTileSize.width, KalGridViewTileSize.height));
	}
}
- (void) resetState
{
	// Realign to the grid
	CGRect frame = self.frame;
	frame.origin = self.origin;
	frame.size = KalGridViewTileSize;
	self.frame = frame;
  
	self.date = nil;
	self.type = KalTileViewTypeRegular;
	self.highlighted = NO;
	self.selected = NO;
	self.marked = NO;
}
- (void) setDate: (KalDate *) aDate
{
	if (_date == aDate)
		return;

	_date = aDate;
	[self setNeedsDisplay];
}
- (void) setHighlighted: (BOOL) highlighted
{
	if (_highlighted == highlighted)
		return;
	
	_highlighted = highlighted;
	[self setNeedsDisplay];
}
- (void) setSelected:(BOOL)selected
{
	if (_selected == selected)
		return;

	// Workaround since I cannot draw outside of the frame in drawRect:
	if (!self.isToday)
	{
		CGRect rect = self.frame;
		if (selected)
		{
			rect.origin.x--;
			rect.size.width++;
			rect.size.height++;
		}
		else
		{
			rect.origin.x++;
			rect.size.width--;
			rect.size.height--;
		}
		self.frame = rect;
	}
  
	_selected = selected;
	[self setNeedsDisplay];
}
- (void) setMarked: (BOOL) marked
{
	if (_marked == marked)
		return;
  
	_marked = marked;
	[self setNeedsDisplay];
}
- (void) setType: (KalTileViewType) tileType
{
	if (_type == tileType)
		return;
  
	// Workaround since I cannot draw outside of the frame in drawRect:
	CGRect rect = self.frame;
	if (tileType == KalTileViewTypeToday)
	{
		rect.origin.x--;
		rect.size.width++;
		rect.size.height++;
	}
	else if (_type == KalTileViewTypeToday)
	{
		rect.origin.x++;
		rect.size.width--;
		rect.size.height--;
	}
	self.frame = rect;
  
	_type = tileType;
	[self setNeedsDisplay];
}

@end
