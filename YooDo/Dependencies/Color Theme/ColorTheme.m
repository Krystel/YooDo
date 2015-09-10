//
//  ColorTheme.m
//  Tictail
//
//  Created by Krystel Chaccour on 9/4/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//


#import "ColorTheme.h"

@implementation ColorTheme

+(UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

#pragma mark - B/W/G
#pragma mark

+(UIColor *)grey_bcg
{
    return [self colorFromHexString:grey_bcg];
}

#pragma mark - Colors
#pragma mark 

+(UIColor *)red_btn
{
    return [self colorFromHexString:red_btn];
}

+(UIColor *)blue
{
    return [self colorFromHexString:blue];
}

+(UIColor *)green
{
    return [self colorFromHexString:green];
}

@end
