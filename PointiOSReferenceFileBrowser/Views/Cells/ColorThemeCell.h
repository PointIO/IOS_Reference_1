//
//  ColorThemeCell.h
//  iPractice
//
//  Created by jb on 11/16/12.
//  Copyright (c) 2012 aletheia Management Partners, llc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorThemeCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel      *colorThemeColorNameLabel;
@property (nonatomic, strong) IBOutlet UIImageView      *colorThemeColorImage;
@property (nonatomic, strong) IBOutlet UIColor      *colorThemeColor;

@end
