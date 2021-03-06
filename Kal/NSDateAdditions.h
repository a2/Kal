/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <Foundation/Foundation.h>

@interface NSDate (KalAdditions)

// All of the following methods use [NSCalendar currentCalendar] to perform
// their calculations.

- (NSDate *) cc_dateByMovingToBeginningOfDay;
- (NSDate *) cc_dateByMovingToEndOfDay;
- (NSDate *) cc_dateByMovingToFirstDayOfTheFollowingMonth;
- (NSDate *) cc_dateByMovingToFirstDayOfTheMonth;
- (NSDate *) cc_dateByMovingToFirstDayOfThePreviousMonth;

- (NSDateComponents *) cc_componentsForMonthDayAndYear;

- (NSUInteger) cc_numberOfDaysInMonth;
- (NSUInteger) cc_weekday;

@end