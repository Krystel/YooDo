//
//  DatePickerCell.m
//  Tictail
//
//  Created by Krystel Chaccour on 9/6/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import "DatePickerCell.h"

@implementation DatePickerCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.fake_view = [[UIView alloc] init];
        [self.fake_view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.fake_view setBackgroundColor:[UIColor whiteColor]];
        [self.fake_view setUserInteractionEnabled:YES];
        [self.contentView addSubview:self.fake_view];

        self.datePicker = [[UIDatePicker alloc] init];
        [self.datePicker setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.datePicker setBackgroundColor:[UIColor whiteColor]];
        [self.datePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [self.datePicker setMinimumDate:[NSDate date]]; // user cannot add a past to-do
        [self.fake_view addSubview:self.datePicker];
        
        self.deleteTask = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.deleteTask setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.deleteTask setImage:[UIImage imageNamed:@"Trash"] forState:UIControlStateNormal];
        [self.deleteTask setEnabled:YES];
        [self.deleteTask setUserInteractionEnabled:YES];
        [self.deleteTask setShowsTouchWhenHighlighted:YES];
        [self.deleteTask addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.fake_view addSubview:self.deleteTask];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.fake_view forKey:@"fake"];
        [dict setObject:self.datePicker forKey:@"picker"];
        [dict setObject:self.deleteTask forKey:@"delete"];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[fake]-10-|" options:0 metrics:nil views:dict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[fake]-5-|" options:0 metrics:nil views:dict]];
    
        [self.fake_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[picker]-0-|" options:0 metrics:nil views:dict]];
        [self.fake_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[picker(180)]" options:0 metrics:nil views:dict]];

        [self.fake_view addConstraint:[NSLayoutConstraint constraintWithItem:self.deleteTask attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.fake_view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
        [self.fake_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[picker]-15-[delete]" options:0 metrics:nil views:dict]];
}
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (IBAction)buttonSelected:(UIButton *)sender {
    
    NSInteger index = sender.tag -1;
    [self.delegate deleteButtonSelected:self atIndex:index];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
