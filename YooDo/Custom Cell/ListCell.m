//
//  ListCell.m
//  Tictail
//
//  Created by Krystel Chaccour on 9/6/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import "ListCell.h"

@implementation ListCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.fake_view = [[UIView alloc] init];
        [self.fake_view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.fake_view setBackgroundColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.fake_view];
        
        self.check_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.check_btn setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.check_btn setBackgroundColor:[UIColor clearColor]];
        [self.check_btn setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];
        [self.check_btn addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self.fake_view addSubview:self.check_btn];
        
        self.todo_title = [[UITextField alloc] init];
        [self.todo_title setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.todo_title setBackgroundColor:[UIColor clearColor]];
        [self.todo_title setTextColor:[UIColor darkGrayColor]];
        [self.todo_title setFont:[FontManager bookFontOfSize:15]];
        [self.todo_title setTextAlignment:NSTextAlignmentLeft];
        [self.todo_title setUserInteractionEnabled:NO];
        [self.todo_title setPlaceholder:@"New Task"];
        [self.todo_title setClearButtonMode:UITextFieldViewModeWhileEditing];
        [self.todo_title setKeyboardType:UIKeyboardTypeAlphabet];
        [self.todo_title setAutocapitalizationType:UITextAutocapitalizationTypeSentences];
        [self.todo_title sizeToFit];
        [self.fake_view addSubview:self.todo_title];
        
        self.todo_date = [[UILabel alloc] init];
        [self.todo_date setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.todo_date setBackgroundColor:[UIColor clearColor]];
        [self.todo_date setTextColor:[ColorTheme blue]];
        [self.todo_date setFont:[FontManager lightFontOfSize:12]];
        [self.todo_date setTextAlignment:NSTextAlignmentLeft];
        [self.todo_date sizeToFit];
        [self.fake_view addSubview:self.todo_date];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:self.todo_title forKey:@"title"];
        [dict setObject:self.todo_date forKey:@"date"];
        [dict setObject:self.fake_view forKey:@"fake"];
        [dict setObject:self.check_btn forKey:@"check"];
        int width = self.contentView.frame.size.width - 50; // 20 , 30, 5, 15
        [dict setObject:[NSNumber numberWithInt:width] forKey:@"width"];
        
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[fake]-10-|" options:0 metrics:nil views:dict]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-5-[fake]-0-|" options:0 metrics:nil views:dict]];

        [self.fake_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[check(30)]" options:0 metrics:nil views:dict]];
        [self.fake_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[check(30)]" options:0 metrics:nil views:dict]];
        [self.fake_view addConstraint:[NSLayoutConstraint constraintWithItem:self.check_btn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.fake_view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

        [self.fake_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[check]-15-[title(==width)]" options:0 metrics:dict views:dict]];
        [self.fake_view addConstraint:[NSLayoutConstraint constraintWithItem:self.todo_title attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.fake_view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:-10.0]];

        [self.fake_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[check]-15-[date]" options:0 metrics:nil views:dict]];
        [self.fake_view addConstraint:[NSLayoutConstraint constraintWithItem:self.todo_date attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.fake_view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:10.0]];
    }
    
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (IBAction)buttonSelected:(UIButton *)sender {
    
    sender.selected = !sender.selected;
    NSInteger index = sender.tag;
    
    [self.delegate checkButtonSelected:self atIndex:index selected:sender.selected];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
