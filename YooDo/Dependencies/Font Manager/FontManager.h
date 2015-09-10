//
//  FontManager.h
//  Tictail
//
//  Created by Krystel Chaccour on 9/4/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FontManager : NSObject

+(UIFont*) bookFontOfSize:(CGFloat)pointSize;
+(UIFont*) lightFontOfSize:(CGFloat)pointSize;
+(UIFont*) thinFontOfSize:(CGFloat)pointSize;
+(UIFont*) extraLightFontOfSize:(CGFloat)pointSize;


@end
