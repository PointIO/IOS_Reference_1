//
//  Common.m
//  
//
//  Created by jb on 6/19/13.
//
//

#import "Common.h"

@implementation Common


+(BOOL) isConnectedToInternet {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}


+(UIColor *)theColor:(NSInteger) index:(NSInteger) numberOfItems {

    //
    // Purpose
    // For a set of tableViewRows, obtain a color gradient for each successive row to created descending gradient effect
    //
    // Returns  UIColor
    // Input:   index           =   the index of the curent row that needs a color returned
    // Input:   numberOfItems   =   the number of rows over which the color will be displayed
    //

    NSUInteger itemCount = (numberOfItems - 1);
    float val = ((float)index / (float)itemCount) * 0.6;
    
    NSString *defaultColorTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultColorTheme"];
    if ([defaultColorTheme isEqualToString:@"Blue"]) {
        return [UIColor colorWithRed:0.0 green:val blue:1.0 alpha:1.0];
    }
    else if ([defaultColorTheme isEqualToString:@"Green"]) {
        return [UIColor colorWithRed:0.0 green:1.0 blue:val alpha:1.0];
    }
    else if ([defaultColorTheme isEqualToString:@"Red"]) {
        return [UIColor colorWithRed:1.0 green:val blue:0.0 alpha:1.0];
    }
    else if ([defaultColorTheme isEqualToString:@"Yellow"]) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:val alpha:1.0];
    }
    else if ([defaultColorTheme isEqualToString:@"White"]) {
        return [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
    }
    else {
        return [UIColor colorWithRed:0.0 green:val blue:1.0 alpha:1.0];
    }
}


+(UIColor *)theTableViewBackgroundColor {
    //
    // Purpose
    // Evaluate currentDefaultTheme color and return appropriate UIColor
    //
    // Returns: UIColor
    // Input:   N/A
    //
    
    NSString *defaultColorTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultColorTheme"];
    if ([defaultColorTheme isEqualToString:@"Blue"]) {
        return [UIColor blueColor];
    }
    else if ([defaultColorTheme isEqualToString:@"Green"]) {
        return [UIColor greenColor];
    }
    else if ([defaultColorTheme isEqualToString:@"Red"]) {
        return [UIColor redColor];
    }
    else if ([defaultColorTheme isEqualToString:@"Yellow"]) {
        return [UIColor yellowColor];
    }
    else if ([defaultColorTheme isEqualToString:@"White"]) {
        return [UIColor groupTableViewBackgroundColor];
    }
    else {
        return [UIColor blueColor];
    }
}


+(BOOL)isDefaultColorThemeWhite {
    //
    // Purpose
    // Evaluate currentDefaultTheme color and return TRUE for White, FALSE otherwise
    //
    // Returns  BOOL
    // Input:   N/A
    //
    
    NSString *defaultColorTheme = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultColorTheme"];
    if ([defaultColorTheme isEqualToString:@"Blue"]) {
        return FALSE;
    }
    else if ([defaultColorTheme isEqualToString:@"Green"]) {
        return FALSE;
    }
    else if ([defaultColorTheme isEqualToString:@"Red"]) {
        return FALSE;
    }
    else if ([defaultColorTheme isEqualToString:@"Yellow"]) {
        return FALSE;
    }
    else if ([defaultColorTheme isEqualToString:@"White"]) {
        return TRUE;
    }
    else {
        return NO;
    }
}


+(BOOL)shouldUseGradient {
    //
    // Purpose
    // Evaluate Global setting for turning Gradient on or off
    //
    // Returns  BOOL
    // Input:   N/A
    //
    
    return FALSE;
    
}




@end
