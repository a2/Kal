/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalView.h"
#import "KalGridView.h"
#import "KalLogic.h"
#import "KalPrivate.h"

@interface KalView ()

@property (nonatomic, strong) KalLogic *logic;
@property (nonatomic, strong) KalGridView *gridView;
@property (nonatomic, strong) UIImageView *shadowView;
@property (nonatomic, strong) UILabel *headerTitleLabel;
@property (nonatomic, strong) UITableView *tableView;

- (void) addSubviewsToHeaderView: (UIView *) headerView;
- (void) addSubviewsToContentView: (UIView *) contentView;
- (void) setHeaderTitleText: (NSString *) text;

@end

static const CGFloat KalViewHeaderHeight = 44.f;
static const CGFloat KalViewMonthLabelHeight = 17.f;

@implementation KalView

- (BOOL) isSliding
{
	return self.gridView.transitioning;
}

- (id) initWithFrame: (CGRect) frame
{
	[NSException raise: @"Incomplete Initializer" format: @"KalView must be initialized with a KalLogic. Use the initWithFrame:logic: method."];
	return nil;
}
- (id) initWithFrame: (CGRect) frame logic: (KalLogic *) theLogic
{
	if ((self = [super initWithFrame: frame]))
	{
		self.logic = theLogic;
		[self.logic addObserver: self forKeyPath: @"localizedMonthAndYear" options: NSKeyValueObservingOptionNew context: NULL];
		
		self.autoresizesSubviews = YES;
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	}
	
	return self;
}

- (KalDate *) selectedDate
{
	return self.gridView.selectedDate;
}

- (void) addSubviewsToContentView: (UIView *) contentView
{
	// Both the tile grid and the list of events will automatically lay themselves
	// out to fit the # of weeks in the currently displayed month.
	// So the only part of the frame that we need to specify is the width.
	CGRect fullWidthAutomaticLayoutFrame = CGRectMake(0.f, 0.f, self.width, 0.f);
	
	// The tile grid (the calendar body)
	self.gridView = [[KalGridView alloc] initWithFrame:fullWidthAutomaticLayoutFrame logic: self.logic];
	self.gridView.delegate = self.delegate;
	[self.gridView addObserver: self forKeyPath: @"frame" options: NSKeyValueObservingOptionNew context: NULL];
	[contentView addSubview: self.gridView];
	
	// The list of events for the selected day
	self.tableView = [[UITableView alloc] initWithFrame: fullWidthAutomaticLayoutFrame style:UITableViewStylePlain];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	[contentView addSubview: self.tableView];
	
	// Drop shadow below tile grid and over the list of events for the selected day
	self.shadowView = [[UIImageView alloc] initWithFrame:fullWidthAutomaticLayoutFrame];
	self.shadowView.image = [UIImage imageNamed:@"Kal.bundle/kal_grid_shadow.png"];
	self.shadowView.height = self.shadowView.image.size.height;
	[contentView addSubview: self.shadowView];
	
	// Trigger the initial KVO update to finish the contentView layout
	[self.gridView sizeToFit];
}
- (void) addSubviewsToHeaderView: (UIView *) headerView
{
	const CGFloat KalViewChangeMonthButtonWidth = 46.0f;
	const CGFloat KalViewChangeMonthButtonHeight = 30.0f;
	const CGFloat KalViewMonthLabelWidth = 200.0f;
	const CGFloat KalViewHeaderVerticalAdjust = 3.f;
	
	// Header background gradient
	UIImageView *backgroundView = [[UIImageView alloc] initWithImage: [UIImage imageNamed: @"Kal.bundle/kal_grid_background.png"]];
	CGRect imageFrame = headerView.frame;
	imageFrame.origin = CGPointZero;
	backgroundView.frame = imageFrame;
	[headerView addSubview: backgroundView];
	
	// Create the previous month button on the left side of the view
	CGRect previousMonthButtonFrame = CGRectMake(self.left, KalViewHeaderVerticalAdjust, KalViewChangeMonthButtonWidth, KalViewChangeMonthButtonHeight);
	UIButton *previousMonthButton = [[UIButton alloc] initWithFrame: previousMonthButtonFrame];
	previousMonthButton.accessibilityLabel = NSLocalizedString(@"Previous month", nil);
	previousMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	previousMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	[previousMonthButton addTarget: self action: @selector(showPreviousMonth) forControlEvents: UIControlEventTouchUpInside];
	[previousMonthButton setImage: [UIImage imageNamed:@"Kal.bundle/kal_left_arrow.png"] forState:UIControlStateNormal];
	[headerView addSubview: previousMonthButton];
	
	// Draw the selected month name centered and at the top of the view
	CGRect monthLabelFrame = CGRectMake((self.width/2.0f) - (KalViewMonthLabelWidth/2.0f), KalViewHeaderVerticalAdjust, KalViewMonthLabelWidth, KalViewMonthLabelHeight);
	self.headerTitleLabel = [[UILabel alloc] initWithFrame:monthLabelFrame];
	self.headerTitleLabel.backgroundColor = [UIColor clearColor];
	self.headerTitleLabel.font = [UIFont boldSystemFontOfSize:22.f];
	self.headerTitleLabel.textAlignment = UITextAlignmentCenter;
	self.headerTitleLabel.textColor = [UIColor colorWithPatternImage: [UIImage imageNamed: @"Kal.bundle/kal_header_text_fill.png"]];
	self.headerTitleLabel.shadowColor = [UIColor whiteColor];
	self.headerTitleLabel.shadowOffset = CGSizeMake(0, 1);
	
	[self setHeaderTitleText: self.logic.localizedMonthAndYear];
	[headerView addSubview: self.headerTitleLabel];
	
	// Create the next month button on the right side of the view
	CGRect nextMonthButtonFrame = CGRectMake(self.width - KalViewChangeMonthButtonWidth, KalViewHeaderVerticalAdjust, KalViewChangeMonthButtonWidth, KalViewChangeMonthButtonHeight);
	UIButton *nextMonthButton = [[UIButton alloc] initWithFrame: nextMonthButtonFrame];
	nextMonthButton.accessibilityLabel = NSLocalizedString(@"Next month", nil);
	nextMonthButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
	nextMonthButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
	
	[nextMonthButton addTarget: self action: @selector(showFollowingMonth) forControlEvents: UIControlEventTouchUpInside];
	[nextMonthButton setImage: [UIImage imageNamed:@"Kal.bundle/kal_right_arrow.png"] forState: UIControlStateNormal];
	[headerView addSubview: nextMonthButton];
	
	// Add column labels for each weekday (adjusting based on the current locale's first weekday)
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	dateFormatter.locale = [NSLocale currentLocale];
	NSArray *weekdayNames = dateFormatter.shortWeekdaySymbols;
	NSArray *fullWeekdayNames = dateFormatter.standaloneWeekdaySymbols;
	NSUInteger firstWeekday = [[NSCalendar currentCalendar] firstWeekday];
	NSUInteger i = firstWeekday - 1;
	for (CGFloat xOffset = 0; xOffset < headerView.width; xOffset += 46.f, i = (i + 1) % 7)
	{
		CGRect weekdayFrame = CGRectMake(xOffset, 30.f, 46.f, KalViewHeaderHeight - 29.f);
		UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:weekdayFrame];
		weekdayLabel.backgroundColor = [UIColor clearColor];
		weekdayLabel.font = [UIFont boldSystemFontOfSize:10.f];
		weekdayLabel.textAlignment = UITextAlignmentCenter;
		weekdayLabel.textColor = [UIColor colorWithRed:0.3f green:0.3f blue:0.3f alpha:1.f];
		weekdayLabel.shadowColor = [UIColor whiteColor];
		weekdayLabel.shadowOffset = CGSizeMake(0.f, 1.f);
		weekdayLabel.text = weekdayNames[i];
		
		[weekdayLabel setAccessibilityLabel: fullWeekdayNames[i]];
		[headerView addSubview: weekdayLabel];
	}
}
- (void) dealloc
{
	[self.logic removeObserver: self forKeyPath: @"localizedMonthAndYear"];
	[self.gridView removeObserver: self forKeyPath: @"frame"];
}
- (void) markTilesForDates: (NSArray *) dates
{
	[self.gridView markTilesForDates: dates];
}
- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object change: (NSDictionary *) change context: (void *) context
{
	if ([object isEqual: self.gridView] && [keyPath isEqualToString: @"frame"])
	{
		/* Animate tableView filling the remaining space after the
		 * gridView expanded or contracted to fit the # of weeks
		 * for the month that is being displayed.
		 *
		 * This observer method will be called when gridView's height
		 * changes, which we know to occur inside a Core Animation
		 * transaction. Hence, when I set the "frame" property on
		 * tableView here, I do not need to wrap it in a
		 * [UIView beginAnimations:context:].
		 */
		CGFloat gridBottom = self.gridView.top + self.gridView.height;
		CGRect frame = self.tableView.frame;
		frame.origin.y = gridBottom;
		frame.size.height = self.tableView.superview.height - gridBottom;
		self.tableView.frame = frame;
		self.shadowView.top = gridBottom;
	}
	else if ([keyPath isEqualToString:@"localizedMonthAndYear"])
	{
		[self setHeaderTitleText: change[NSKeyValueChangeNewKey]];
	}
	else
	{
		[super observeValueForKeyPath: keyPath ofObject: object change: change context: context];
	}
}
- (void) redrawEntireMonth
{
	[self slide: KalGridViewSlideTypeNone];
}
- (void) selectDate: (KalDate *) date
{
	[self.gridView selectDate: date];
}
- (void) setDelegate: (id <KalViewDelegate>) aDelegate
{
	if (_delegate == aDelegate)
		return;
	
	[self.subviews makeObjectsPerformSelector: @selector(removeFromSuperview)];
	
	_delegate = aDelegate;

	UIView *headerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, self.frame.size.width, KalViewHeaderHeight)];
	headerView.backgroundColor = [UIColor grayColor];
	[self addSubviewsToHeaderView: headerView];
	[self addSubview: headerView];
    
	UIView *contentView = [[UIView alloc] initWithFrame: CGRectMake(0, KalViewHeaderHeight, self.frame.size.width, self.frame.size.height - KalViewHeaderHeight)];
	contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
	[self addSubviewsToContentView: contentView];
	[self addSubview: contentView];
}
- (void) setHeaderTitleText: (NSString *) text
{
	self.headerTitleLabel.text = text;
	[self.headerTitleLabel sizeToFit];
	
	self.headerTitleLabel.left = floorf(0.5 * (self.width - self.headerTitleLabel.width));
}
- (void) showFollowingMonth
{
	if (!self.gridView.transitioning)
		[self.delegate showFollowingMonth];
}
- (void) showPreviousMonth
{
	if (!self.gridView.transitioning)
		[self.delegate showPreviousMonth];
}
- (void) slide: (KalGridViewSlideType) slideType
{
	[self.gridView slide: slideType];
}

@end
