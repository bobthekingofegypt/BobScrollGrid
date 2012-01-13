//
//  BSGEntryViewTest.m
//  BobScrollGrid
//
//  Copyright (c) 2011 Richard Martin. All rights reserved.
//  Licensed under the terms of the BSD License, see LICENSE.txt
//

#import <GHUnitIOS/GHUnit.h> 
#import "BSGEntryView.h"

@interface BSGEntryViewTest : GHTestCase { }
@end

@implementation BSGEntryViewTest

-(void)testInitWithFrameAndReuse {       
    CGRect frame = CGRectMake(20.0f, 25.0f, 10.0f, 11.0f);
    BSGEntryView *bsgEntryView = [[BSGEntryView alloc] initWithFrame:frame 
                                                  andReuseIdentifier:@"testidentifier"];
    
    GHAssertEqualObjects(@"testidentifier", bsgEntryView.reuseIdentifier, @"Reuse identifier should be set to testidentifier");
    GHAssertTrue(CGRectEqualToRect(frame, bsgEntryView.frame), @"check that the frame was set in parent view");
    
    GHAssertNotNil(bsgEntryView.contentView, @"contentView should not be nil");
    GHAssertNotNil(bsgEntryView.selectedBackgroundView, @"selectedBackgroundView should not be nil");
    GHAssertNil(bsgEntryView.backgroundView, @"backgroundView should be nil");
}

-(void) testPrepareForReuse {
    BSGEntryView *bsgEntryView = [[BSGEntryView alloc] initWithFrame:CGRectZero
                                                  andReuseIdentifier:@"testidentifier"];
    [bsgEntryView setSelected:YES animated:NO];
    [bsgEntryView setHighlighted:YES animated:NO];
    
    GHAssertTrue(bsgEntryView.selected, @"entry view should be selected");
    GHAssertTrue(bsgEntryView.highlighted, @"entry view should be highlighted");
    
    [bsgEntryView prepareForReuse];
    
    GHAssertFalse(bsgEntryView.selected, @"entry view should not be selected");
    GHAssertFalse(bsgEntryView.highlighted, @"entry view should not be highlighted");
}

-(void) testSetSelected {
    BSGEntryView *bsgEntryView = [[BSGEntryView alloc] initWithFrame:CGRectZero
                                                  andReuseIdentifier:@"testidentifier"];
    
    [bsgEntryView setSelected:YES];
    GHAssertTrue(bsgEntryView.selected, @"entry view should be selected");
    
    [bsgEntryView setSelected:NO];
    GHAssertFalse(bsgEntryView.selected, @"entry view should not be selected"); 
}

-(void) testSetSelectedAnimated {
    BSGEntryView *bsgEntryView = [[BSGEntryView alloc] initWithFrame:CGRectZero
                                                  andReuseIdentifier:@"testidentifier"];

    [bsgEntryView setSelected:YES animated:NO];
    GHAssertTrue(bsgEntryView.selected, @"entry view should be selected");
    
    [bsgEntryView setSelected:NO animated:NO];
    GHAssertFalse(bsgEntryView.selected, @"entry view should not be selected"); 
    
    [bsgEntryView setSelected:YES animated:YES];
    GHAssertTrue(bsgEntryView.selected, @"entry view should be selected");
    
    [bsgEntryView setSelected:NO animated:YES];
    GHAssertFalse(bsgEntryView.selected, @"entry view should not be selected"); 
}

-(void) testSetHighlighted {
    BSGEntryView *bsgEntryView = [[BSGEntryView alloc] initWithFrame:CGRectZero
                                                  andReuseIdentifier:@"testidentifier"];
    
    [bsgEntryView setHighlighted:YES animated:NO];
    GHAssertTrue(bsgEntryView.highlighted, @"entry view should be highlighted");
    
    [bsgEntryView setHighlighted:NO animated:NO];
    GHAssertFalse(bsgEntryView.highlighted, @"entry view should not be highlighted"); 
    
    [bsgEntryView setHighlighted:YES animated:YES];
    GHAssertTrue(bsgEntryView.highlighted, @"entry view should be highlighted");
    
    [bsgEntryView setHighlighted:NO animated:YES];
    GHAssertFalse(bsgEntryView.highlighted, @"entry view should not be highlighted"); 
}

-(void) testSetHighlightedAnimated {
    BSGEntryView *bsgEntryView = [[BSGEntryView alloc] initWithFrame:CGRectZero
                                                  andReuseIdentifier:@"testidentifier"];
    
    [bsgEntryView setHighlighted:YES];
    GHAssertTrue(bsgEntryView.highlighted, @"entry view should be highlighted");
    
    [bsgEntryView setHighlighted:NO];
    GHAssertFalse(bsgEntryView.highlighted, @"entry view should not be highlighted"); 
}

@end
