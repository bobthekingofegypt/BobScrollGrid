//
//  BSGViewTempController.m
//  BobScrollGridExample
//
//  Created by Richard Martin on 08/12/2011.
//  Copyright (c) 2011 Richard Martin. All rights reserved.
//

#import "BSGViewTempController.h"
#import "BSGEntryView.h"

@implementation BSGViewTempController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    [super loadView];
    //self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    bsgView_ = [[BSGView alloc] initWithFrame:CGRectMake(0.0f,0.0f,self.view.bounds.size.width, self.view.bounds.size.height)];
    //bsgView_.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    bsgView_.backgroundColor = [UIColor redColor];
    bsgView_.datasource = self;
    bsgView_.bsgViewDelegate = self;
    bsgView_.entrySize = CGSizeMake(72.0f, 72.0f);
    bsgView_.entryPadding = UIEdgeInsetsMake(2.0f, 2.0f, 2.0f, 2.0f);
    [bsgView_ reloadData];
    
    [self.view addSubview:bsgView_];
}

-(BSGEntryView *) bsgView:(BSGView *)bsgView viewForEntryAtIndexPath:(NSIndexPath *)indexPath {
    BSGEntryView *entry = [[[BSGEntryView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, bsgView_.entrySize.width, bsgView_.entrySize.height) andReuseIdentifier:@"test"] autorelease];
    entry.contentView.backgroundColor = [UIColor blueColor];
    
    UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 10.0f, 50.0f, 20.0f)];
    //l.text = [NSString stringWithFormat:@"%d", [bsgView_ indexForEntryAtIndexPath:indexPath]];
    [entry.contentView addSubview:l];
    [l release];
    
    return entry;
}

/**
 Asks the datasource to return the number of entries to be displayed.
 @return entryCount The number of entries in the BSGView.
 */
-(NSInteger) entryCount {
    return 118;
}

-(NSInteger) numberOfEntriesPerRow {
    return 4;
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

@end
