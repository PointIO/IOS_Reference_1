//
//  ColorThemeCell.m
//  iPractice
//
//  Created by jb on 11/16/12.
//  Copyright (c) 2012 aletheia Management Partners, llc. All rights reserved.
//

#import "ColorThemeCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation ColorThemeCell

{
    CAGradientLayer* _gradientLayer;
}


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // add a layer that overlays the cell adding a subtle gradient effect
        _gradientLayer          = [CAGradientLayer layer];
        _gradientLayer.frame    = self.bounds;
        _gradientLayer.colors   = @[(id)[[UIColor colorWithWhite:1.0f alpha:0.2f] CGColor],
        (id)[[UIColor colorWithWhite:1.0f alpha:0.1f] CGColor],
        (id)[[UIColor clearColor] CGColor],
        (id)[[UIColor colorWithWhite:0.0f alpha:0.1f] CGColor]];
        _gradientLayer.locations = @[@0.00f, @0.01f, @0.95f, @1.00f];
        
        [self.layer insertSublayer:_gradientLayer atIndex:0];
        
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}



-(void) layoutSubviews
{
    [super layoutSubviews];
    // ensure the gradient layers occupies the full bounds
    _gradientLayer.frame = self.bounds;
}

@end
