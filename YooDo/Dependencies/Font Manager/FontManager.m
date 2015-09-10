//
//  FontManager.m
//  Tictail
//
//  Created by Krystel Chaccour on 9/4/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import "FontManager.h"

@implementation FontManager

#pragma mark - Default Fonts

+(UIFont*) bookFontOfSize:(CGFloat)pointSize
{
    return [UIFont fontWithName:@"Gotham-Book" size:pointSize];
}

+(UIFont*) lightFontOfSize:(CGFloat)pointSize {
    return [UIFont fontWithName:@"Gotham-Light" size:pointSize];
}

+(UIFont*) thinFontOfSize:(CGFloat)pointSize {
    return [UIFont fontWithName:@"Gotham-Thin" size:pointSize];
}

+(UIFont*) extraLightFontOfSize:(CGFloat)pointSize {
    return [UIFont fontWithName:@"Gotham-ExtraLight" size:pointSize];
}


@end
