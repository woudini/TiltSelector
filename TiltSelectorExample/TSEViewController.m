//
//  ViewController.m
//  TiltSelectorExample
//
//  Created by Woudini on 3/18/15.
//  Copyright (c) 2015 Hi Range. All rights reserved.
//

#import "TSEViewController.h"
#import "TSEDataSource.h"
#import "TSESecondViewController.h"
@interface TSEViewController ()

#define RAPSegueNotification @"RAPSegueNotification"
#define RAPGetRectSelectorShapesNotification @"RAPGetRectSelectorShapesNotification"

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) TSEDataSource *dataSource;

@end

@implementation TSEViewController

#pragma mark Protocol

#pragma mark Notify superclass to get rect selector shapes

-(void)segueWhenSelectedRow
{
    if (super.rectangleSelector.cellIndex == super.rectangleSelector.cellMax)
    {
        [super calibrate];
    }
    else
    {
        [self performSegueWithIdentifier:@"segue" sender:nil];        
    }
}

-(void)addSelfAsObserverForSegueWhenSelectedRow
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(segueWhenSelectedRow) name:RAPSegueNotification object:nil];
}

-(void)notifySuperclassToGetRectSelectorShapes
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RAPGetRectSelectorShapesNotification object:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"segue"])
    {
        NSIndexPath *indexPath;
        if (![self.tableView indexPathForSelectedRow])
        {
            // User has used the tilt mechanism to select a row;
            indexPath = [self.tableView indexPathForCell:[[self.tableView visibleCells] objectAtIndex:super.rectangleSelector.cellIndex]];
        }
        else // Otherwise, the user has tapped the row, so use the row that was tapped
        {
            indexPath = [self.tableView indexPathForSelectedRow];
            [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
        }
        
        TSESecondViewController *secondViewController = segue.destinationViewController;
        secondViewController.selectedRow = (int)indexPath.row;
    }
}

- (void)setupDataSource
{
    __weak TSEViewController *weakSelf = self;
    
    UITableViewCell* (^configureCellBlock)(NSIndexPath *indexPath) = ^(NSIndexPath *indexPath) {
        UITableViewCell *tableViewCell = [weakSelf.tableView dequeueReusableCellWithIdentifier:@"cell"];
        tableViewCell.textLabel.text = [[NSString alloc] initWithFormat:@"%ld", (long)indexPath.row];
        return tableViewCell;
    };
    
    NSInteger (^numberOfRowsBlock)() = ^NSInteger() {
        return 15;
    };
    
    self.dataSource = [[TSEDataSource alloc] initWithConfigureCellBlock:configureCellBlock
                                             NumberOfRowsInSectionBlock:numberOfRowsBlock];
    self.tableView.dataSource = self.dataSource;
    self.tableView.delegate = self.dataSource;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self addSelfAsObserverForSegueWhenSelectedRow];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupDataSource];
    [self notifySuperclassToGetRectSelectorShapes];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
