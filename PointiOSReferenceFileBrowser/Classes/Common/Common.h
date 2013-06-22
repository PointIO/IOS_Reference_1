//
//  Common.h
//  
//
//  Created by jb on 6/19/13.
//
//

#import <UIKit/UIKit.h>
#import "Reachability.h"


@interface Common : NSObject
{
    
}

+(BOOL)isConnectedToInternet;


+ (UIColor *)theColor:(NSInteger) index:(NSInteger) numberOfItems;
+ (UIColor *)theTableViewBackgroundColor;
+ (BOOL)isDefaultColorThemeWhite;
+ (BOOL)shouldUseGradient;


@end

