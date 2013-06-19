//
//  Common.m
//  
//
//  Created by jb on 6/19/13.
//
//

#import "Common.h"

@implementation Common

+(BOOL) isConnectedToInternet{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

@end
