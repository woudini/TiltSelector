//
//  RAPRectangleSelector.m
//  redditAPI
//
//  Created by Woudini on 2/7/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "RAPRectangleSelector.h"
@interface RAPRectangleSelector ()
@property (nonatomic) UIColor *rectColor;
@property (nonatomic) CGFloat rectRedCGFloat;
@property (nonatomic) CGFloat rectGreenCGFloat;
@property (nonatomic) CGFloat rectBlueCGFloat;
@property (nonatomic) NSTimer *changeColorTimer;
@property (nonatomic) CGRect initialFrame;
@property (nonatomic) BOOL atTop;
@property (nonatomic) CGRect toolBarRect;

@end
@implementation RAPRectangleSelector

-(id)initWithFramesMutableArray:(NSMutableArray *)mutableArray atTop:(BOOL)atTop withCellMax:(int)cellMax inWebView:(BOOL)isInWebView inInitialFrame:(CGRect)frame withToolbarRect:(CGRect)toolbarRect
{
    if (atTop)
    {
        if (self = [super initWithFrame:frame])
        {
            self.rectsMutableArray = [[NSMutableArray alloc] initWithArray:mutableArray];
            self.atTop = atTop;
            self.initialFrame = frame;
            self.toolBarRect = toolbarRect;
            self.cellMax = cellMax;
            self.isStationary = isInWebView;
            [self setup];
        }
    }
    
    else if (!atTop)
    {
        if (self = [super initWithFrame:toolbarRect])
        {
            self.rectsMutableArray = [[NSMutableArray alloc] initWithArray:mutableArray];
            self.atTop = atTop;
            self.initialFrame = toolbarRect;
            self.toolBarRect = toolbarRect;
            self.cellMax = cellMax;
            self.isStationary = isInWebView;
            [self setup];
        }
    }
    // NSLog(@"%lu objects in rectsMutableArray: %@", [self.rectsMutableArray count], self.rectsMutableArray);
    return self;
}

-(void)awakeFromNib
{
    [self setup];
}

-(void)setup
{
    self.opaque = NO;
    self.backgroundColor = [UIColor clearColor];
    [self resetCellIndex];
    [self beginDecrementingAlpha];
}

-(void)resetCellIndex
{
    if (self.atTop)
    {
        self.cellIndex = 0;
    }
    else if (!self.atTop)
    {
        self.cellIndex = self.cellMax;
        self.initialFrame = self.toolBarRect;
    }
}

-(void)reset
{
    [self.changeColorTimer invalidate];
    self.changeColorTimer = nil;
    CGRect newFrame = self.initialFrame;
    self.frame = newFrame;
    [self resetCellIndex];
    //NSLog(@"Newframe is %@", NSStringFromCGRect(self.frame));
    self.currentLocationRect = newFrame;
}

-(void)beginDecrementingAlpha
{
    self.rectColor = [UIColor greenColor];
    self.rectRedCGFloat = 0;
    self.rectGreenCGFloat = 1.0;
    self.rectBlueCGFloat = 0;
    self.changeColorTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(changeColor) userInfo:nil repeats:YES];
}

-(void)changeColor
{
    self.rectColor = [UIColor colorWithRed:self.rectRedCGFloat green:self.rectGreenCGFloat blue:self.rectBlueCGFloat alpha:1];
    
    // Green to yellow
    if (self.rectRedCGFloat < 0.9)
    {
        self.rectRedCGFloat = self.rectRedCGFloat + 0.1;
    }
    else
    {
        self.rectRedCGFloat = 1;
    }
    
    // Yellow to red
    if (self.rectRedCGFloat == 1)
    {
        self.rectGreenCGFloat = self.rectGreenCGFloat - 0.1;
    }
    
    [self setNeedsDisplay];
    
    if (self.rectGreenCGFloat < 0.1)
    {
        if (self.atTop)
        {
            if (self.cellIndex < self.cellMax)
            {
                [self timerEnded];
            }
            else if (self.cellIndex == self.cellMax)
            {
                [self reset];
                [self setup];
            }
        }
        else if (!self.atTop)
        {
            if (self.cellIndex > 0)
            {
                [self timerEnded];
            }
            else if (self.cellIndex == 0)
            {
                [self reset];
                [self setup];
            }
        }
    }
}

-(void)timerEnded
{
    [self.changeColorTimer invalidate];
    self.changeColorTimer = nil;
    
    if (self.isStationary)
    {
        [self beginDecrementingAlpha];
    }
    else if (!self.isStationary)
    {
        [self moveRect];
    }
}

-(void)incrementOrDecrementCellIndex
{
    if (self.atTop)
    {
        self.cellIndex++;
    }
    else if (!self.atTop)
    {
        self.cellIndex--;
    }
}

-(void)moveRect
{
    [self incrementOrDecrementCellIndex];
    NSLog(@"Cellindex is %d", self.cellIndex);
    CGRect newCell = [[self.rectsMutableArray objectAtIndex:self.cellIndex] CGRectValue];
    // track how far down you are in tableview, and reduce statusbarplusheight by that number
    CGRect newFrame = CGRectMake(newCell.origin.x, newCell.origin.y+self.statusBarPlusNavigationBarHeight-self.currentContentOffset, newCell.size.width, newCell.size.height);
    
    if (self.cellIndex == self.cellMax)
    {
        newFrame = self.toolBarRect;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];
        self.frame = newFrame;
        [UIView commitAnimations];
    });
    
    self.currentLocationRect = newFrame;
    //NSLog(@"Neworigin is %@", NSStringFromCGPoint(self.currentLocationRect.origin));
    
    [self beginDecrementingAlpha];
}

-(void)setCellIndex:(int)cellIndex
{
    if (cellIndex <= self.cellMax)
    {
        _cellIndex = cellIndex;
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Start by filling the area with the blue color
    [self.rectColor setFill];
    UIRectFill( rect );
    
    // Assume that there's an ivar somewhere called holeRect of type CGRect
    // We could just fill holeRect, but it's more efficient to only fill the
    // area we're being asked to draw.
    CGRect holeRect = CGRectMake(5, 5, self.bounds.size.width-10, self.bounds.size.height-10);
    CGRect holeRectIntersection = CGRectIntersection( holeRect, rect );
    
    [[UIColor clearColor] setFill];
    UIRectFill( holeRectIntersection );
    
}


@end
