//
//  ColorThemePickerViewController.h
//  iPractice
//
//  Created by jb on 11/16/12.
//  Copyright (c) 2012 aletheia Management Partners, llc. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import <CoreData/CoreData.h>
// #import "AppDelegate.h"

@class ColorThemePickerViewController;

@protocol ColorThemePickerViewControllerDelegate <NSObject>
- (void)colorThemePickerViewController:(ColorThemePickerViewController *)controller didSelectValue:(NSString *)theSelectedValue;
@end


@interface ColorThemePickerViewController : UITableViewController

@property (nonatomic, weak) id <ColorThemePickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *selectedValue;
@property (nonatomic, strong) NSString *currentValue;
@property (nonatomic, strong) NSMutableDictionary *sourceDictionary;


@end
