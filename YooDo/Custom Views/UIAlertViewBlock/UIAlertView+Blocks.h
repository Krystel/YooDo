//
//  UIAlertView+Blocks.h
//  Tictail
//
//  Created by Krystel Chaccour on 9/8/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView_Blocks : UIAlertView

@property (copy, nonatomic) void (^completion)(BOOL, NSInteger);

-(id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;

@end
