/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import "KalDataSource.h"
#import "KalPrivate.h"

@implementation SimpleKalDataSource

+ (SimpleKalDataSource *) dataSource
{
	return [[self class] new];
}

#pragma mark UITableViewDataSource protocol conformance

- (UITableViewCell *) tableView: (UITableView *) tableView cellForRowAtIndexPath: (NSIndexPath *) indexPath
{
	static NSString *identifier = @"MyCell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
	if (!cell)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	cell.textLabel.text = @"FILLER TEXT";
	return cell;
}

- (NSInteger) tableView: (UITableView *) tableView numberOfRowsInSection: (NSInteger) section
{
  return 0;
}

#pragma mark Kal Data Source

- (NSArray *) markedDatesFrom: (NSDate *) fromDate to: (NSDate *) toDate
{
	return @[];
}

- (void) presentingDatesFrom: (NSDate *) fromDate to: (NSDate *) toDate delegate: (id <KalDataSourceCallbacks>) delegate
{
	[delegate loadedDataSource: self];
}
- (void) loadItemsFromDate: (NSDate *) fromDate toDate: (NSDate *) toDate
{
	// Do nothing
}
- (void) removeAllItems
{
	// Do nothing
}

@end
