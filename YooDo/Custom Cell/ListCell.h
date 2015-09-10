//
//  ListCell.h
//  Tictail
//
//  Created by Krystel Chaccour on 9/6/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

@class ListCell;

@protocol ListCellDelegate
-(void) checkButtonSelected:(ListCell *)cell atIndex:(NSInteger)index selected:(BOOL)selected;

@end

@interface ListCell : UITableViewCell
@property (nonatomic, retain) UIView *fake_view;
@property (nonatomic, retain) UITextField *todo_title;
@property (nonatomic, retain) UILabel *todo_date;
@property (nonatomic, retain) UIButton *check_btn;
@property (nonatomic, assign) IBOutlet id <ListCellDelegate> delegate;

@end
