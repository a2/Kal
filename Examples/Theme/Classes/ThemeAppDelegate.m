/* 
 * Copyright (c) 2010 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "ThemeAppDelegate.h"
#import "EventKitDataSource.h"
#import "Kal.h"
#import "KalTileView.h"
#import "KalMonthView.h"

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@implementation ThemeAppDelegate

@synthesize window = _window;

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *) launchOptions
{
	KalTileView *tileView = [KalTileView appearance];
	[tileView setBackgroundImage: [UIImage imageNamed: @"green"] forState: KalTileViewStateNormal];
	[tileView setBackgroundImage: [UIImage imageNamed: @"dark-green"] forState: KalTileViewStateSelected];
	[tileView setBackgroundImage: [UIImage imageNamed: @"light-green"] forState: KalTileViewStateAdjacent];
	[tileView setBackgroundImage: [UIImage imageNamed: @"blue"] forState: KalTileViewStateAdjacent | KalTileViewStateToday];
	[tileView setTextColor: [UIColor blackColor] forState: KalTileViewStateNormal];
	[tileView setTextColor: [UIColor greenColor] forState: KalTileViewStateToday];
	[tileView setTextColor: [UIColor whiteColor] forState: KalTileViewStateSelected];
	[tileView setTextColor: [UIColor magentaColor] forState: KalTileViewStateSelected | KalTileViewStateToday];
	
	KalMonthView *monthView = [KalMonthView appearance];
	[monthView setBackgroundImage: [UIImage imageNamed: @"light-green"]];
	
	KalView *view = [KalView appearance];
	[view setGridBackgroundImage: [UIImage imageNamed: @"light-green"]];
	[view setGridDropShadowImage: [UIImage imageNamed: @"grid-shadow"]];
	[view setLeftArrowImage: [UIImage imageNamed: @"left-arrow"] forState: UIControlStateNormal];
	[view setRightArrowImage: [UIImage imageNamed: @"right-arrow"] forState: UIControlStateNormal];
	[view setTitleLabelTextColor: [UIColor redColor]];
	[view setWeekdayLabelTextColor: [UIColor purpleColor]];
	
	KalGridView *gridView = [KalGridView appearance];
	[gridView setGridBackgroundColor: [UIColor colorWithRed:0.893 green:0.911 blue:0.788 alpha:1.000]];
	[gridView setGridBackgroundImage: [UIImage imageNamed: @"light-green"]];
	
	/*
	 *    Kal Initialization
	 *
	 * When the calendar is first displayed to the user, Kal will automatically select today's date.
	 * If your application requires an arbitrary starting date, use -[KalViewController initWithSelectedDate:wantsTableView:]
	 * instead of -[KalViewController init].
	 */
	self.kal = [[KalViewController alloc] initWithSelectedDate: [NSDate date] wantsTableView: NO];
	self.kal.title = @"Theme";

	/*
	 *    Kal Configuration
	 *
	 */
	self.kal.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Today" style: UIBarButtonItemStyleBordered target: self action: @selector(showAndSelectToday)];
	self.kal.tableView.delegate = self;
	
	self.dataSource = [[EventKitDataSource alloc] init];
	self.kal.dataSource = self.dataSource;
	self.kal.tableView.dataSource = self.dataSource;

	// Setup the navigation stack and display it.
	self.navigationController = [[UINavigationController alloc] initWithRootViewController: self.kal];
	self.window.rootViewController = self.navigationController;
	
	[self.window addSubview: self.navigationController.view];
	[self.window makeKeyAndVisible];
	
	return YES;
}

// Action handler for the navigation bar's right bar button item.
- (void)showAndSelectToday
{
	[self.kal showAndSelectDate: [NSDate date]];
}

#pragma mark UITableViewDelegate protocol conformance

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath
{
	// Display a details screen for the selected event/row.
	EKEventViewController *vc = [[EKEventViewController alloc] init];
	vc.allowsEditing = NO;
	vc.event = [self.dataSource eventAtIndexPath: indexPath];
	
	[self.navigationController pushViewController: vc animated:YES];
}

#pragma mark -


@end
