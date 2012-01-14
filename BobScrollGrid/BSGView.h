//
//  BSGView.h
//  BobScrollGrid
//
//  Copyright (c) 2011 Richard Martin. All rights reserved.
//  Licensed under the terms of the BSD License, see LICENSE.txt
//

#import <UIKit/UIKit.h>

@class BSGEntryView, BSGView;

typedef enum {
    BSGEntryViewFitToWidth,
    BSGEntryViewFitToHeight,
    BSGEntryViewFitCustom //will call number of entries per row
} BSGEntryViewFit;

/** The datasource of a BSGView must adopt the BSGDatasource protocol. 
 */
@protocol BSGDatasource

/** 
 Asks the datasource to return the entry for the given index path in the BSGView.
 @param bsgView An object representing the BSGView requesting this information.
 @param indexPath The index path of the required BSGEntryView.
 @return BSGEntryView The entry view for this index.
 */
-(BSGEntryView *) bsgView:(BSGView *)bsgView viewForEntryAtIndexPath:(NSIndexPath *)indexPath;

/**
 Asks the datasource to return the number of entries to be displayed.
 @return entryCount The number of entries in the BSGView.
 */
-(NSInteger) entryCount;

@end

/** The delegate of a BSGView must adopt the BSGViewDelegate protocol. 
 */
@protocol BSGViewDelegate<NSObject>

@optional

/** 
 Informs the delegate when a user selects an entry.
 @param bsgView An object representing the BSGView providing this information.
 @param indexPath The index path of the selected BSGEntryView.
 @return BSGEntryView The entry view for this index.
 */
-(void) bsgView:(BSGView *)bsgView didSelectEntryAtIndexPath:(NSIndexPath *)indexPath;

/** 
 Informs the delegate when a user deselects an entry.
 @param bsgView An object representing the BSGView providing this information.
 @param indexPath The index path of the deselected BSGEntryView.
 @return BSGEntryView The entry view for this index.
 */
-(void) bsgView:(BSGView *)bsgView didDeselectEntryAtIndexPath:(NSIndexPath *)indexPath;

@end

/** This is a base class for all BobScrollGrids.  It is a subclass of
 UIScrollView so makes available all functionality of UIScrollViews. 
 */

@interface BSGView : UIScrollView<UIScrollViewDelegate> {
    id<BSGDatasource> _datasource;
	id<BSGViewDelegate> _bsgViewDelegate;
	
	UIEdgeInsets _entryPadding;
	CGSize _entrySize;
	
@private
	CGSize _entrySizeWithPadding;
	NSInteger _numberOfRows;
	NSInteger _entryCount;
	NSInteger _numberOfEntriesPerRow;
	NSMutableDictionary *visibleEntries;
	NSMutableDictionary *reusableEntries;
	NSIndexPath *startingIndexPath;
	NSIndexPath *endingIndexPath;
	BSGEntryView *highlightedEntry;
	NSIndexPath *selectedEntry;
	CGPoint _initialTouchPoint;
	BOOL _touchingAnEntry;
	
	NSInteger entriesOnScreen;
	
	CGRect oldBounds;
	NSMutableDictionary *oldVisibleEntries;
    
    NSInteger preCacheColumnCount;
    
    BSGEntryViewFit bsgEntryViewFitMode;
}

@property (nonatomic, assign) id<BSGDatasource> datasource;
@property (nonatomic, assign) id<BSGViewDelegate> bsgViewDelegate;
@property (nonatomic, assign) UIEdgeInsets entryPadding;
@property (nonatomic, assign) CGSize entrySize;
@property (nonatomic, readonly) NSInteger numberOfEntriesPerRow;
@property (nonatomic, assign) NSInteger preCacheColumnCount;
@property (nonatomic, assign) NSIndexPath *selectedEntry;

-(id) initWithFrame:(CGRect)frame;
-(void) reloadData;
-(BSGEntryView *) dequeReusableEntry:(NSString *)reuseIdentifier;
-(NSArray *) visibleEntries;
-(void) prepareOrientationChange;
-(void) deselectEntryAtIndexPath:(NSIndexPath *)indexPath;
-(void) resetBounds;


///** The object that acts as the data source of the receiving bob scroll grid view. */
//@property (nonatomic, assign) id<BSGDatasource> datasource;
//
///** The object that acts as the view delegate of the receiving bob scroll grid view. */
//@property (nonatomic, assign) id<BSGViewDelegate> bsgViewDelegate;
//
//@property (nonatomic, assign) UIEdgeInsets entryPadding;
//@property (nonatomic, assign) CGSize entrySize;
//
-(NSInteger) indexForEntryAtIndexPath:(NSIndexPath*)p;

@end

#ifndef BSGUtil
#define BSGUtil

NSInteger IndexFromIndexPath(NSIndexPath *path, NSInteger entriesPerRow);
NSIndexPath *IndexPathFromIndex(NSInteger index, NSInteger entriesPerRow);

#endif
