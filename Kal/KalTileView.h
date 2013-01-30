/* 
 * Copyright (c) 2009 Keith Lazuka
 * License: http://www.opensource.org/licenses/mit-license.html
 */

#import <UIKit/UIKit.h>

typedef NS_ENUM(char, KalTileViewType) {
	KalTileViewTypeRegular   = 0,
	KalTileViewTypeAdjacent  = 1 << 0,
	KalTileViewTypeToday     = 1 << 1,
};

@class KalDate;

@interface KalTileView : UIView

@property (nonatomic) KalTileViewType type;
@property (nonatomic) BOOL belongsToAdjacentMonth;
@property (nonatomic, getter = isHighlighted) BOOL highlighted;
@property (nonatomic, getter = isMarked) BOOL marked;
@property (nonatomic, getter = isSelected) BOOL selected;
@property (nonatomic, getter = isToday) BOOL today;
@property (nonatomic, strong) KalDate *date;

- (void) resetState;

@end
