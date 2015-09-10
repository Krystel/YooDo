//
//  UIAlertView+Blocks.m
//  Tictail
//
//  Created by Krystel Chaccour on 9/8/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import "UIAlertView+Blocks.h"

@interface UIAlertView () <UIAlertViewDelegate>

@end

@implementation UIAlertView_Blocks

- (id)initWithTitle:(NSString *)title message:(NSString *)message cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSArray *)otherButtonTitles;
{
    self = [self initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil, nil];
    
    if (self)
    {
        for (NSString *title in otherButtonTitles) {
            [self addButtonWithTitle:title];
        }
    }
    
    return self;
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (self.completion) {
        self.completion(buttonIndex==self.cancelButtonIndex, buttonIndex);
        self.completion = nil;
    }
}

@end
