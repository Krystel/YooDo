//
//  DatePickerCell.h
//  Tictail
//
//  Created by Krystel Chaccour on 9/6/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

@class DatePickerCell;

@protocol DatePickerCellDelegate
-(void) deleteButtonSelected:(DatePickerCell *)cell atIndex:(NSInteger)index;

@end

@interface DatePickerCell : UITableViewCell
@property (nonatomic, retain) UIView *fake_view;
@property (nonatomic, strong) IBOutlet UIDatePicker *datePicker;
@property (nonatomic, strong) IBOutlet UIButton *deleteTask;
@property (nonatomic, assign) IBOutlet id <DatePickerCellDelegate> delegate;

@end
