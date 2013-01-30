/* 
 * Copyright (c) 2010 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "ThemeAppDelegate.h"
#import "EventKitDataSource.h"
#import "Kal.h"

#import <EventKit/EventKit.h>
#import <EventKitUI/EventKitUI.h>

@implementation ThemeAppDelegate

@synthesize window = _window;

- (BOOL) application: (UIApplication *) application didFinishLaunchingWithOptions: (NSDictionary *)launchOptions
{
	/*
	 *    Kal Initialization
	 *
	 * When the calendar is first displayed to the user, Kal will automatically select today's date.
	 * If your application requires an arbitrary starting date, use -[KalViewController initWithSelectedDate:]
	 * instead of -[KalViewController init].
	 */
	self.kal = [[KalViewController alloc] init];
	self.kal.title = @"Theme";

	/*
	 *    Kal Configuration
	 *
	 */
	self.kal.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Today" style:UIBarButtonItemStyleBordered target: self action: @selector(showAndSelectToday)];
	self.kal.delegate = self;
	
	self.dataSource = [[EventKitDataSource alloc] init];
	self.kal.dataSource = self.dataSource;

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
	[self.kal showAndSelectDate:[NSDate date]];
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
