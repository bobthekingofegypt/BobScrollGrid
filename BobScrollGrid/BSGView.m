//
//  BSGView.m
//  BobScrollGrid
//
//  Copyright (c) 2011 Richard Martin. All rights reserved.
//  Licensed under the terms of the BSD License, see LICENSE.txt
//

#import "BSGView.h"
#import "BSGEntryView.h"

NSInteger IndexFromIndexPath(NSIndexPath *path, NSInteger entriesPerRow) {
	return (path.row * entriesPerRow) + path.section;
}

@interface BSGView ()
@property (nonatomic, retain) NSIndexPath *startingIndexPath;
@property (nonatomic, retain) NSIndexPath *endingIndexPath;
@end


@interface BSGView (Private)
-(void) redrawForLocation:(CGPoint)scrollLocation;
-(void) removeAllVisibleItems;

-(void) removeVisibleItemForX:(NSInteger)x andY:(NSInteger)y;
-(void) removePreviouslyVisibleEntriesForStartingIndex:(NSIndexPath *)newStartingIndex 
										andEndingIndex:(NSIndexPath *)newEndingIndex;
-(void) addNewVisibleEntriesForStartingIndex:(NSIndexPath *)newStartingIndex 
                              andEndingIndex:(NSIndexPath *)newEndingIndex;
-(void) drawEntryForIndexPath:(NSIndexPath *)key;

-(void) prepareForBSGEntryViewFitToWidthMode;
-(void) prepareForBSGEntryViewFitToHeightMode;
-(void) prepareForBSGEntryViewFitCustom;
@end



@implementation BSGView

@synthesize datasource; 
@synthesize bsgViewDelegate;
@synthesize entryPadding;
@synthesize entrySize;
@synthesize startingIndexPath;
@synthesize endingIndexPath;
@synthesize numberOfEntriesPerRow;
@synthesize preCacheColumnCount;
@synthesize selectedEntry;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
	if (self) {
        bsgEntryViewFitMode = BSGEntryViewFitToWidth;
        
		self.datasource = nil;
		self.bsgViewDelegate = nil;
		
		self.startingIndexPath = nil;
		self.endingIndexPath = nil;
		highlightedEntry = nil;
		selectedEntry = nil;
		
		self.entryPadding = UIEdgeInsetsZero;
		self.entrySize = CGSizeZero;
		
		numberOfRows = 0;
		numberOfEntriesPerRow = 0;
		
		visibleEntries = [[NSMutableDictionary alloc] init];
		reusableEntries = [[NSMutableDictionary alloc] init];
        
		self.backgroundColor = [UIColor whiteColor];
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		self.userInteractionEnabled = YES;
		self.scrollEnabled = YES;
		self.bsgViewDelegate = nil;
        
        preCacheColumnCount = 0;
	}
	
	return self;
}

-(void) dealloc {
	self.datasource = nil;
	self.bsgViewDelegate = nil;
	[startingIndexPath release], startingIndexPath = nil;
	[endingIndexPath release], endingIndexPath = nil;
	[highlightedEntry release], highlightedEntry = nil;
	[selectedEntry release], selectedEntry = nil;
	[visibleEntries release], visibleEntries = nil;
	[reusableEntries release], reusableEntries = nil;
	
	[super dealloc];
}

#pragma mark -
#pragma mark Public API methods
#pragma mark -

-(void) deselectEntryAtIndexPath:(NSIndexPath *)indexPath {
    BSGEntryView *entry = [visibleEntries objectForKey:indexPath];
    [entry setHighlighted:NO animated:NO];
    [entry setSelected:NO animated:YES];
}

-(void) reloadData {
	self.startingIndexPath = nil;
	self.endingIndexPath = nil;
    
	entryCount = [self.datasource entryCount];
    
    NSInteger entryWidthWithPadding = (self.entrySize.width + self.entryPadding.left + self.entryPadding.right);
    NSInteger entryHeightWithPadding = (self.entrySize.height + self.entryPadding.top + self.entryPadding.bottom);
    entrySizeWithPadding = CGSizeMake(entryWidthWithPadding, entryHeightWithPadding);
	
    switch (bsgEntryViewFitMode) {
        case BSGEntryViewFitToWidth:
            [self prepareForBSGEntryViewFitToWidthMode];
            break;
        case BSGEntryViewFitToHeight:
            [self prepareForBSGEntryViewFitToHeightMode];
            break;
        default:
            [self prepareForBSGEntryViewFitCustom];
            break;
    }    
	
	[self removeAllVisibleItems];
	
	oldBounds = self.bounds;
    
    [self redrawForLocation:self.contentOffset];
}

-(NSInteger) indexForEntryAtIndexPath:(NSIndexPath*)indexPath {
    return (indexPath.row * numberOfEntriesPerRow) + indexPath.section;
}

-(BSGEntryView *) dequeReusableEntry:(NSString *)reuseIdentifier {
    
	NSMutableSet *set = [reusableEntries objectForKey:reuseIdentifier];
	if (set != nil) {
		BSGEntryView *entry = [set anyObject];
		if (entry != nil) {
			[[entry retain] autorelease];
			[set removeObject:entry];
            [entry prepareForReuse];
		}
		return entry;
	}
	
	return nil;
}

-(void) resetBounds {
	[startingIndexPath release], startingIndexPath = nil;
	[endingIndexPath release], endingIndexPath = nil;
	
	entryCount = [self.datasource entryCount];
	numberOfEntriesPerRow = [self.datasource numberOfEntriesPerRow];
	numberOfRows = ceil(entryCount / (double)numberOfEntriesPerRow);
    
	NSInteger entryWidthWithPadding = (self.entrySize.width + self.entryPadding.left + self.entryPadding.right);
	NSInteger entryHeightWithPadding = (self.entrySize.height + self.entryPadding.top + self.entryPadding.bottom);
	entrySizeWithPadding = CGSizeMake(entryWidthWithPadding, entryHeightWithPadding);
	
	NSInteger contentWidth = ceil((entrySizeWithPadding.width) * numberOfEntriesPerRow);
	NSInteger contentHeight = ceil((entrySizeWithPadding.height) * numberOfRows);
	self.contentSize = CGSizeMake(contentWidth, contentHeight);
	
	oldBounds = self.bounds;
}


#pragma mark -
#pragma mark Private methods
#pragma mark -

-(void) prepareForBSGEntryViewFitToWidthMode {
    NSInteger contentWidth = self.bounds.size.width;
    numberOfEntriesPerRow = floor(contentWidth / entrySizeWithPadding.width);
    
    double spareSpace = contentWidth - (numberOfEntriesPerRow * self.entrySize.width);
    NSInteger padding = (spareSpace / (numberOfEntriesPerRow + 1)) / 2;
    entrySizeWithPadding = CGSizeMake(self.entrySize.width + (padding * 2), entrySizeWithPadding.height);
    
    self.entryPadding = UIEdgeInsetsMake(self.entryPadding.top, padding, self.entryPadding.bottom, padding);
    
    self.contentInset = UIEdgeInsetsMake(self.contentInset.top, 0.0f, self.contentInset.bottom, 0.0f);
    
    numberOfRows = ceil(entryCount / (float)numberOfEntriesPerRow);
    
    NSInteger contentHeight = ceil((entrySizeWithPadding.height) * numberOfRows);
    self.contentSize = CGSizeMake(self.bounds.size.width - (padding * 2), contentHeight);
}

-(void) prepareForBSGEntryViewFitToHeightMode {
    [NSException raise:@"not implemented" format:@""];
}

-(void) prepareForBSGEntryViewFitCustom {
    if (![self.datasource respondsToSelector:@selector(numberOfEntriesPerRow)]) {
        [NSException raise:@"Custom mode error" format:@"You cannot use custom mode without implementing number of entries per row"];
    }
          
    numberOfEntriesPerRow = [self.datasource numberOfEntriesPerRow];
    numberOfRows = ceil(entryCount / (double)numberOfEntriesPerRow);
    
    NSInteger entryWidthWithPadding = (self.entrySize.width + self.entryPadding.left + self.entryPadding.right);
    NSInteger entryHeightWithPadding = (self.entrySize.height + self.entryPadding.top + self.entryPadding.bottom);
    entrySizeWithPadding = CGSizeMake(entryWidthWithPadding, entryHeightWithPadding);
    
    NSInteger contentWidth = ceil((entrySizeWithPadding.width) * numberOfEntriesPerRow);
    NSInteger contentHeight = ceil((entrySizeWithPadding.height) * numberOfRows);
    self.contentSize = CGSizeMake(contentWidth, contentHeight);
}

-(void) removeAllVisibleItems {
	NSArray *indexes = [visibleEntries allKeys];
	for (NSIndexPath *index in indexes) {
		[self removeVisibleItemForX:index.section andY:index.row];
	}
}

-(void) removeVisibleItemForX:(NSInteger)x andY:(NSInteger)y {
	NSIndexPath *key = [NSIndexPath indexPathForRow:y inSection:x];
	BSGEntryView *entry = [visibleEntries objectForKey:key];
    
	if (entry != nil) {
		[[entry retain] autorelease];
		[entry removeFromSuperview];
		[visibleEntries removeObjectForKey:key];
		NSString *entryKey = [[entry.reuseIdentifier copy] autorelease];
		NSMutableSet *set = [reusableEntries objectForKey:entryKey];
		if (set == nil) {
			set = [[[NSMutableSet alloc] init] autorelease];
		}
		[set addObject:entry];
		
		[reusableEntries setObject:set forKey:entryKey];
		entriesOnScreen -= 1;
	}
}

- (void)redrawForLocation:(CGPoint)scrollLocation {    
	NSInteger minXIndex = MAX(floor(scrollLocation.x / entrySizeWithPadding.width), 0);
	NSInteger maxXIndex = MIN(ceil((scrollLocation.x + self.frame.size.width) / entrySizeWithPadding.width), 
							  numberOfEntriesPerRow);
	
	NSInteger minYIndex = MAX(floor(scrollLocation.y / entrySizeWithPadding.height) - preCacheColumnCount, 0);
	NSInteger maxYIndex =  MIN((ceil((scrollLocation.y + self.frame.size.height) / entrySizeWithPadding.height) + preCacheColumnCount), 
							   numberOfRows);
	
	NSIndexPath *newStartingIndex = [NSIndexPath indexPathForRow:minYIndex inSection:minXIndex];
	NSIndexPath *newEndingIndex = [NSIndexPath indexPathForRow:maxYIndex inSection:maxXIndex];
	
	[self removePreviouslyVisibleEntriesForStartingIndex:newStartingIndex andEndingIndex:newEndingIndex];	
	[self addNewVisibleEntriesForStartingIndex:newStartingIndex andEndingIndex:newEndingIndex];
	
	self.startingIndexPath = [NSIndexPath indexPathForRow:minYIndex inSection:minXIndex];
	self.endingIndexPath = [NSIndexPath indexPathForRow:maxYIndex inSection:maxXIndex];
}

-(void) removePreviouslyVisibleEntriesForStartingIndex:(NSIndexPath *)newStartingIndex 
										andEndingIndex:(NSIndexPath *)newEndingIndex {
	BOOL movedBackwards = (startingIndexPath.section > newStartingIndex.section);
	BOOL movedUp = (startingIndexPath.row > newStartingIndex.row);
    
    NSInteger startX =  movedBackwards ? newEndingIndex.section : startingIndexPath.section;
    NSInteger endX = movedBackwards ? endingIndexPath.section : newStartingIndex.section;
    
    NSInteger startY = movedUp ? newEndingIndex.row : startingIndexPath.row;
    NSInteger endY = movedUp ? endingIndexPath.row : newStartingIndex.row;
    
    for (NSInteger x = startX; x < endX; ++x) {
        for (NSInteger y = startingIndexPath.row; y < newEndingIndex.row; ++y) {
            [self removeVisibleItemForX:x andY:y];
        }
    }
	
	NSInteger redrawXStart = movedBackwards ? startingIndexPath.section : endX;
	NSInteger redrawXEnd = movedBackwards ? startX : endingIndexPath.section;
    
    for (NSInteger y = startY; y < endY; ++y) {
        for (NSInteger x = redrawXStart; x < redrawXEnd; ++x) {
            [self removeVisibleItemForX:x andY:y];
        }
    }
}

-(void) addNewVisibleEntriesForStartingIndex:(NSIndexPath *)newStartingIndex 
                              andEndingIndex:(NSIndexPath *)newEndingIndex {
	BOOL movedBackwards = (startingIndexPath.section > newStartingIndex.section);
	BOOL movedUp = (startingIndexPath.row > newStartingIndex.row);
	
	NSInteger startX =  movedBackwards ? newStartingIndex.section : endingIndexPath.section;
	NSInteger endX = movedBackwards ? startingIndexPath.section : newEndingIndex.section;
	
	NSInteger startY = movedUp ? newStartingIndex.row : endingIndexPath.row;
	NSInteger endY = movedUp ? startingIndexPath.row : newEndingIndex.row;
	
    for (NSInteger y = newStartingIndex.row; y < newEndingIndex.row; ++y) {
        for (NSInteger x = startX; x < endX; ++x) {
			NSIndexPath *key = [NSIndexPath indexPathForRow:y inSection:x];
            BSGEntryView *entry = [visibleEntries objectForKey:key];
			if (entry) {
				continue;
            }
            [self drawEntryForIndexPath:key];
		}
	}
	
	NSInteger redrawXStart = movedBackwards ? endX : newStartingIndex.section;
	NSInteger redrawXEnd = movedBackwards ? newEndingIndex.section : startX;
	
	for (NSInteger y = startY; y < endY; ++y) {
		for (NSInteger x = redrawXStart; x < redrawXEnd; ++x) {
			NSIndexPath *key = [NSIndexPath indexPathForRow:y inSection:x];
			
			if ([visibleEntries objectForKey:key])
				continue;
			[self drawEntryForIndexPath:key];
		}
	}
}

-(void) drawEntryForIndexPath:(NSIndexPath *)key {
	NSInteger index = IndexFromIndexPath(key, numberOfEntriesPerRow);
	if (index >= entryCount) {
		return;
	}
	BSGEntryView *entry = [self.datasource bsgView:self viewForEntryAtIndexPath:key];
	
	NSInteger xPoint = self.entryPadding.left + (key.section * entrySizeWithPadding.width) + self.entryPadding.left;
	NSInteger yPoint = (key.row * entrySizeWithPadding.height) + self.entryPadding.top;
	entry.frame = CGRectMake(xPoint, yPoint, self.entrySize.width, self.entrySize.height);
	
	if (xPoint > (self.contentOffset.x + self.frame.size.width)) {
		xPoint = self.contentOffset.x + self.frame.size.width;
	}
	if (yPoint > (self.contentOffset.y + self.frame.size.height)) {
		yPoint = self.contentOffset.y + self.frame.size.height;
		
	}
	
	if (!entry.superview) {
		if (!self.dragging) {
			[self addSubview:entry];
		} else {
			[self addSubview:entry];
		}
		entriesOnScreen += 1;
	}
	[visibleEntries setObject:entry forKey:key];
}

-(BOOL) isValidIndex:(NSInteger)x andY:(NSInteger)y {
	return ((y * numberOfEntriesPerRow) + x < entryCount) &&
    (x < numberOfEntriesPerRow);
}

-(BOOL) isValidIndexPath:(NSIndexPath *)indexPath {
	return [self isValidIndex:indexPath.section andY:indexPath.row];
}

-(NSIndexPath *) indexPathForPoint:(CGPoint)point {
	NSInteger x = point.x / entrySizeWithPadding.width;
	NSInteger y = point.y / entrySizeWithPadding.height;
	return [NSIndexPath indexPathForRow:y inSection:x];
}

-(void) updateSelectedEntry:(NSIndexPath *) path {
	if (![self isValidIndexPath:path]) {
		return;
	}	
	[highlightedEntry setSelected:YES animated:NO];
	[highlightedEntry release], highlightedEntry = nil;
	
	if ([self.bsgViewDelegate respondsToSelector:@selector(bsgView:didDeselectEntryAtIndexPath:)]) {
		[self.bsgViewDelegate bsgView:self didDeselectEntryAtIndexPath:selectedEntry];
	} else {
		BSGEntryView *entry = [visibleEntries objectForKey:selectedEntry];
		if (entry != nil) {
			[entry setSelected:NO animated:YES];
		}
	}
    
	[selectedEntry release], selectedEntry = nil;
	
	selectedEntry = [path retain];
	if ([self.bsgViewDelegate respondsToSelector:@selector(bsgView:didSelectEntryAtIndexPath:)]) {
		[self.bsgViewDelegate bsgView:self didSelectEntryAtIndexPath:selectedEntry];
	}
}

-(void) layoutSubviews {
	[super layoutSubviews];
	if (entriesOnScreen == entryCount) {
		return;
	}
	if (entrySize.width == 0 || entrySize.height == 0) {
		return;
	}
    
    if (!CGSizeEqualToSize(oldBounds.size, self.bounds.size)) {
        [self reloadData];
    } else {
        [self redrawForLocation:self.contentOffset];
    }
}


-(NSArray *) visibleEntries {
    return [visibleEntries allValues];
}


#pragma mark -
#pragma mark Touch handling code
#pragma mark -

-(void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
	CGPoint point = [[touches anyObject] locationInView:self];
	initialTouchPoint = point;
	
	NSIndexPath *path = [self indexPathForPoint:point];
	BSGEntryView *entry = [visibleEntries objectForKey:path];	
	if (entry != nil && CGRectContainsPoint(entry.frame, point)) {
		touchingAnEntry = YES;
		highlightedEntry = [entry retain];
		[entry setHighlighted:YES animated:NO];
	}	
}

-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!touchingAnEntry) {
		return;
	}
	
	CGPoint point = [[touches anyObject] locationInView:self];
	if (highlightedEntry == nil || !CGRectContainsPoint(highlightedEntry.frame, point)) {
		touchingAnEntry = NO;
		[highlightedEntry setHighlighted:NO animated:NO];
		[highlightedEntry release], highlightedEntry = nil;
	}
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	if (!touchingAnEntry) {
		[self touchesCancelled:touches withEvent:event];
		return;
	}
	
	CGPoint point = [[touches anyObject] locationInView:self];
	NSIndexPath *path = [self indexPathForPoint:point];
	[self updateSelectedEntry:path];
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
	touchingAnEntry = NO;
	if (highlightedEntry != nil) {
		[highlightedEntry setHighlighted:NO animated:NO];
		[highlightedEntry release], highlightedEntry = nil;
	}
}

@end
