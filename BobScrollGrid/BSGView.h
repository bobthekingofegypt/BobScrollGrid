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
@protocol BSGDatasource <NSObject>

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

@optional

-(NSInteger) numberOfEntriesPerRow;


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
    id<BSGDatasource> datasource;
	id<BSGViewDelegate> bsgViewDelegate;
	
	UIEdgeInsets entryPadding;
	CGSize entrySize;
    
	NSInteger numberOfEntriesPerRow;
	NSInteger numberOfRows;
    NSInteger entryCount;
    
	CGSize entrySizeWithPadding;
    
    CGPoint initialTouchPoint;
	BOOL touchingAnEntry;
	
	NSMutableDictionary *visibleEntries;
	NSMutableDictionary *reusableEntries;
	NSIndexPath *startingIndexPath;
	NSIndexPath *endingIndexPath;
	BSGEntryView *highlightedEntry;
	NSIndexPath *selectedEntry;
	
	NSInteger entriesOnScreen;
	
	CGRect oldBounds;
    
    NSInteger preCacheColumnCount;
    
    BSGEntryViewFit bsgEntryViewFitMode;
}

/**---------------------------------------------------------------------------------------
 * @name Managing the delegate and the datasource
 *  ---------------------------------------------------------------------------------------
 */

/** The datasource for this scroll grid */
@property (nonatomic, assign) id<BSGDatasource> datasource;

/** The delegate for this scroll grid */
@property (nonatomic, assign) id<BSGViewDelegate> bsgViewDelegate;

/**---------------------------------------------------------------------------------------
 * @name Configuring the scroll grid
 *  ---------------------------------------------------------------------------------------
 */

/** The minimum padding around each entry */
@property (nonatomic, assign) UIEdgeInsets entryPadding;

/** Size to be allocated for each entry */
@property (nonatomic, assign) CGSize entrySize;

/** read only property for access to the number of entries per row */
@property (nonatomic, readonly) NSInteger numberOfEntriesPerRow;

/** number of extra columns to be precached without having to scroll, extends both ways */
@property (nonatomic, assign) NSInteger preCacheColumnCount;

/** returns the currently selected entry */
@property (nonatomic, assign) NSIndexPath *selectedEntry;

/** Returns a reusable entry view object with the given identifier 
 @param identifier The reuse identifier used to identify the entry type 
 @return entry a reusable entry view object 
 */
-(BSGEntryView *) dequeReusableEntry:(NSString *)reuseIdentifier;

/** Triggers a re-calculation of the scroll grids bounds */
-(void) resetBounds;

/**---------------------------------------------------------------------------------------
 * @name Reload the scroll gird data
 *  ---------------------------------------------------------------------------------------
 */

/** Reloads the scroll grid data from the datasource */
-(void) reloadData;

/**---------------------------------------------------------------------------------------
 * @name Accessing the scroll grid entries
 *  ---------------------------------------------------------------------------------------
 */

/** Returns an array of the entries visible on screen */
-(NSArray *) visibleEntries;

/** deselects the entry at the given index path 
 @param indexPath the index path
 */
-(void) deselectEntryAtIndexPath:(NSIndexPath *)indexPath;

/** returns the sequential index for a given index path */
-(NSInteger) indexForEntryAtIndexPath:(NSIndexPath*)indexPath;

@end

#ifndef BSGUtil
#define BSGUtil

NSInteger IndexFromIndexPath(NSIndexPath *path, NSInteger entriesPerRow);
NSIndexPath *IndexPathFromIndex(NSInteger index, NSInteger entriesPerRow);

#endif
