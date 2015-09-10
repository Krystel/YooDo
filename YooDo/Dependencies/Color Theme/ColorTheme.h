//
//  ColorTheme.h
//  Tictail
//
//  Created by Krystel Chaccour on 9/4/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

static NSString *grey_bcg = @"#EEEEEE";
static NSString *red_btn = @"#DB4437";
static NSString *blue = @"#52A1C5";
static NSString *green = @"#53BC71";

@interface ColorTheme : NSObject

//  convert hexadecimal colors to UIColor
+(UIColor *)colorFromHexString:(NSString *)hexString;

+(UIColor *)grey_bcg;
+(UIColor *)red_btn;
+(UIColor *)blue;
+(UIColor *)green;

@end
