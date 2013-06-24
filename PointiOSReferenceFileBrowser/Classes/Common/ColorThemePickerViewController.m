//
//  ColorThemePickerViewController.m
//  iPractice
//
//  Created by jb on 11/16/12.
//  Copyright (c) 2012 aletheia Management Partners, llc. All rights reserved.
//

#import "ColorThemePickerViewController.h"
#import "ColorThemeCell.h"

@interface ColorThemePickerViewController ()

@end

@implementation ColorThemePickerViewController

{
    NSUInteger selectedIndex;
}

@synthesize delegate;
@synthesize sourceDictionary;


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self)
    {
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.sourceDictionary == nil)
	{
		NSString *path                  = [[NSBundle mainBundle] pathForResource:@"AppContent" ofType:@"plist"];
		NSMutableDictionary* tmpDict    = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
		self.sourceDictionary           = tmpDict;
        
        self.tableView.delegate         = self;
        self.tableView.separatorStyle   = UITableViewCellSeparatorStyleNone;
        self.tableView.backgroundColor  = [UIColor blackColor];
        
        // [self.tableView registerClass:[PracticeCell class] forCellReuseIdentifier:@"PracticeCell"];
    }
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}



- (NSString *)documentsDirectory
{
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  	return 1 ;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // NSLog(@"Number of Rows in Color Picker is %u", [[self.sourceDictionary valueForKey:@"colorsList"] count] );
    return [[self.sourceDictionary valueForKey:@"colorsList"] count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ColorThemeCell *cell            = (ColorThemeCell *)[tableView dequeueReusableCellWithIdentifier:@"ColorThemeCell"];
    cell.textLabel.backgroundColor  = [UIColor clearColor];
    NSDictionary *currentColor      = [[self.sourceDictionary valueForKey:@"colorsList"] objectAtIndex:indexPath.row];
    cell.colorThemeColorImage.image = [UIImage imageNamed:[currentColor objectForKey:@"ColorArt"]];
    
    return cell;
}





#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (selectedIndex != NSNotFound)
    {
        UITableViewCell *cell   = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]];
        cell.accessoryType      = UITableViewCellAccessoryNone;
    }
    selectedIndex = indexPath.row;
    
    NSDictionary *currentColor      = [[self.sourceDictionary valueForKey:@"colorsList"] objectAtIndex:indexPath.row];
    NSString *theSelectedColorName  = [currentColor objectForKey:@"ColorName"];
    
    [[NSUserDefaults standardUserDefaults] setValue:theSelectedColorName forKey:@"defaultColorTheme"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *defaultColorTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultColorTheme"];

    NSLog(@"Inside ColorThemePickerVC, didSelectRow, after setting color, new NSUserDefaults Color is %@", defaultColorTheme);

    [self.delegate colorThemePickerViewController:self didSelectValue:theSelectedColorName];

}


#pragma mark  - Data

-(void)reloadFetchedResults
{
    [self.tableView reloadData];
}



#pragma mark
#pragma Core Graphics
/*

-(UIColor*)colorForIndex:(NSInteger) index
{
    NSUInteger itemCount = [self.fetchedResultsController.fetchedObjects count] - 1;
    float val = ((float)index / (float)itemCount) * 0.6;
    return [UIColor colorWithRed: 0.0 green:val blue: 1.0 alpha:1.0];
}



#pragma mark - UITableViewDataDelegate protocol methods
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50.0f;
}



-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [self colorForIndex:indexPath.row];
}


*/



@end
