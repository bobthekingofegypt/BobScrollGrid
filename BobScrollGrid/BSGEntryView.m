//
//  BSGEntryView.m
//  BobScrollGrid
//
//  Copyright (c) 2011 Richard Martin. All rights reserved.
//  Licensed under the terms of the BSD License, see LICENSE.txt
//

#import "BSGEntryView.h"

#define kDefaultSelectedTransparency 0.4

@interface BSGEntryView()
-(void)selectedAnimationStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
-(void)highlightedAnimationStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

@implementation BSGEntryView

@synthesize selected = selected_;
@synthesize highlighted = highlighted_;
@synthesize reuseIdentifier = reuseIdentifier_;
@synthesize backgroundView;
@synthesize selectedBackgroundView;
@synthesize contentView;

-(id)initWithFrame:(CGRect)frame andReuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithFrame:frame])) {
        reuseIdentifier_ = [reuseIdentifier copy];
		
		contentView = [[UIView alloc] initWithFrame:frame];
		
		selectedBackgroundView = [[UIView alloc] initWithFrame:frame];
		selectedBackgroundView.backgroundColor = [UIColor blackColor];
		selectedBackgroundView.alpha = kDefaultSelectedTransparency;
		selectedBackgroundView.hidden = YES;
        
		[self addSubview:selectedBackgroundView];
        [self addSubview:contentView];
    }
    return self;
}

-(void) dealloc {
    [reuseIdentifier_ release];
    [backgroundView release];
    [selectedBackgroundView release];
    [contentView release];
    
    [super dealloc];
}

-(void) prepareForReuse {
	[self setSelected:NO animated:NO];
    [self setHighlighted:NO animated:NO];
}

-(void) setSelected:(BOOL)selected {
	[self setSelected:selected animated:NO];
}

-(void) setSelected:(BOOL)selected animated:(BOOL)animated {
	selected_ = selected;
	if (!animated) {
		selectedBackgroundView.hidden = !selected_;
	} else {
        selectedBackgroundView.alpha = (!selected_ ? kDefaultSelectedTransparency : 0.0);
        selectedBackgroundView.hidden = NO;
        [UIView beginAnimations:@"selected" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(selectedAnimationStopped:finished:context:)];
        [selectedBackgroundView setAlpha:(selected_ ? kDefaultSelectedTransparency : 0.0)];
        [UIView commitAnimations];
	}
}

-(void) setHighlighted:(BOOL)highlighted {
	[self setHighlighted:highlighted animated:NO];
}

-(void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	highlighted_ = highlighted;
	if (!animated) {
		selectedBackgroundView.hidden = !highlighted_;
	} else {
        selectedBackgroundView.alpha = (!highlighted_ ? kDefaultSelectedTransparency : 0.0);
        selectedBackgroundView.hidden = NO;
        [UIView beginAnimations:@"highlighted" context:NULL];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:0.25];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(highlightedAnimationStopped:finished:context:)];
        [selectedBackgroundView setAlpha:(highlighted_ ? kDefaultSelectedTransparency : 0.0)];
        [UIView commitAnimations];
	}
}

-(void)selectedAnimationStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    selectedBackgroundView.hidden = !selected_; 
}

-(void)highlightedAnimationStopped:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    selectedBackgroundView.hidden = !highlighted_; 
}

@end
