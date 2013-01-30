/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>

@class KalTileView, KalDate;

@interface KalMonthView : UIView

@property (nonatomic) NSUInteger numberOfWeeks;

- (KalTileView *) firstTileOfMonth;
- (KalTileView *) tileForDate: (KalDate *) date;

- (void) markTilesForDates: (NSArray *) dates;
- (void) showDates: (NSArray *) mainDates leadingAdjacentDates: (NSArray *) leadingAdjacentDates trailingAdjacentDates: (NSArray *) trailingAdjacentDates;

@end
