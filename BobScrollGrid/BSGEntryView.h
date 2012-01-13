//
//  BSGEntryView.h
//  BobScrollGrid
//
//  Copyright (c) 2011 Richard Martin. All rights reserved.
//  Licensed under the terms of the BSD License, see LICENSE.txt
//

#import <UIKit/UIKit.h>

/** This is a base class for all BobScrollGrid entries.  It is a subclass of
 UIView so makes available all functionality of UIViews.
 
 This class is designed to be subclassed and does not provide any implementation.  
 You can create an instance of this class and add views directly to its contentView 
 if you do not wish to subclass.
 
*/
@interface BSGEntryView : UIView {
  @package
    BOOL selected_;
    BOOL highlighted_;
    
    NSString *reuseIdentifier_;

	UIView *backgroundView;
	UIView *selectedBackgroundView;
	UIView *contentView;
}

/**---------------------------------------------------------------------------------------
 * @name Initializing a BSGEntryView object
 *  ---------------------------------------------------------------------------------------
 */

/** 
 Initializes and returns a newly allocated BSGEntryView object with the secified frame and reuse identifier 
 
 @param frame A CGRect to be used as the views frame.
 @param reuseIdentifier A string that can unique identify this type of entry for use when recycling entries.
 @return An initialized view object or nil if the object couldn't be created.
 */
-(id)initWithFrame:(CGRect)frame andReuseIdentifier:(NSString *)reuseIdentifier;

/**---------------------------------------------------------------------------------------
 * @name Managing Entry Selection and Highlighting
 *  ---------------------------------------------------------------------------------------
 */

/** Whether or not the current entry has been selected */
@property (nonatomic, readonly) BOOL selected;

/** Whether or not the current view is being highlighted */
@property (nonatomic, readonly) BOOL highlighted;

/**
 Sets the current entry view to selected
 
 @param selected whether the view is selected or not
 */
-(void) setSelected:(BOOL)selected;

/** 
 Sets the current entry view to selected
 
 @param selected whether the view is selected or not
 @param animated whether or not to animate the selection state change
 */
-(void) setSelected:(BOOL)selected animated:(BOOL)animated;

/** 
 Sets the current entry view to highlighted
 
 @param highlighted whether the view is highlighted or not
 */

-(void) setHighlighted:(BOOL)highlighted;

/** 
 Sets the current entry view to highlighted
 
 @param highlighted whether the view is highlighted or not
 @param animated whether or not to animate the selection state change
 */
-(void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated;

/**---------------------------------------------------------------------------------------
 * @name Managing Entry views
 *  ---------------------------------------------------------------------------------------
 */

/** The background view for this BSGEntryView */
@property (nonatomic, retain) UIView *backgroundView;

/** The selected background view for this BSGEntryView.  This view is shown when the
 entry is selected or currently highlighted */
@property (nonatomic, retain) UIView *selectedBackgroundView;

/** The content view for this BSGEntryView.  This view is shown above the background view but 
 below the selectedBackgroundView */
@property (nonatomic, retain) UIView *contentView;

/**---------------------------------------------------------------------------------------
 * @name Managing Entry reuse
 *  ---------------------------------------------------------------------------------------
 */

/** The reuseIdentifier for this BSGEntryView */
@property (nonatomic, readonly) NSString *reuseIdentifier;

/**
 Prepare the entry view for reuse.
 Subclasses should override this method to remove any state from this entry so it 
 is ready to be reused.
 */
-(void) prepareForReuse;

@end
