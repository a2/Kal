/* 
 * Copyright (c) 2010 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>

/*
 *    ThemeAppDelegate
 *    --------------------
 *
 *  This demo app shows how to use Kal to display events
 *  from EventKit (Apple's native calendar database).
 *
 */

@class KalViewController;

@interface ThemeAppDelegate : NSObject <UIApplicationDelegate, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) id dataSource;
@property (nonatomic, strong) KalViewController *kal;
@property (nonatomic, strong) UINavigationController *navigationController;

@end
