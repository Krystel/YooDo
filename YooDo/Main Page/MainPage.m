//
//  MainPage.m
//  Tictail
//
//  Created by Krystel Chaccour on 9/4/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import "MainPage.h"
#import <HPReorderTableView/HPReorderTableView.h>
#import "ListCell.h"
#import "DatePickerCell.h"

@interface MainPage () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, ListCellDelegate, DatePickerCellDelegate>
{
    IQKeyboardReturnKeyHandler *returnHandler;
}

@property (nonatomic, strong) NSDate *dateUpdated;
@property (nonatomic, strong) NSString *titleUpdate;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, retain) UIButton *plus_button;
@property (nonatomic, retain) NSMutableArray *listArray;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) IBOutlet UITableView *list_table;
@property (nonatomic) BOOL isOpen, isNew;

@end

@implementation MainPage

-(void)viewDidLoad {
    [super viewDidLoad];

    self.isOpen = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reorderData:) name:@"reorder" object:nil];
    
    // Set date format: Sept 06 2015 04:17 PM
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setLocale:[NSLocale currentLocale]];
    [self.dateFormatter setDateFormat:@"MMM dd yyyy hh:mm a"];
    
    // Handle keyboard: next, previous behavior and resign/dismiss
    returnHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnHandler setDelegate:self];
    [returnHandler setToolbarManageBehaviour:IQAutoToolbarByPosition];
    [returnHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
    
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[IQKeyboardManager sharedManager] setPlaceholderFont:[FontManager bookFontOfSize:13]];
    [[IQKeyboardManager sharedManager] setPreventShowingBottomBlankSpace:YES];
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:YES];
    
    // Add a button pinned at the bottom of the screen for add and done actions
    [self.plus_button removeFromSuperview];
    self.plus_button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.plus_button setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.plus_button setTag:88];
    [self.plus_button setBackgroundImage:[UIImage imageNamed:@"Add_btn"] forState:UIControlStateNormal];
    [self.plus_button addTarget:self action:@selector(plusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.plus_button];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:self.plus_button forKey:@"plus"];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[plus]-10-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[plus]-10-|" options:0 metrics:nil views:dict]];
  
    // Get all info from Database to populate the list
    [self retrieveData];
    
    // Create and load custom table view
    [self loadTableView];
}

#pragma mark - Table View
#pragma mark

-(void)loadTableView
{
    // Create tableview of class HPReorderTableView which handles the reorder/move of the cells
    self.list_table = [[HPReorderTableView alloc] init];
    [self.list_table setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.list_table setDelegate:self];
    [self.list_table setDataSource:self];
    [self.list_table setBackgroundColor:[ColorTheme grey_bcg]];
    [self.list_table setBounces:YES];
    [self.list_table setScrollEnabled:YES];
    [self.list_table setScrollsToTop:YES];
    [self.list_table setUserInteractionEnabled:YES];
    [self.list_table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.list_table];
    [self.view bringSubviewToFront:self.plus_button];
    
    // register table with custom table view cell class: listcell (for custom display of info) and DatePickerViewCell (for the "drop down" date picker inline wiht the row)
    [self.list_table registerClass:[ListCell class] forCellReuseIdentifier:@"listcell"];
    [self.list_table registerClass:[DatePickerCell class] forCellReuseIdentifier:@"DatePickerViewCell"];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_list_table]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_list_table)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[_list_table]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_list_table)]];
}

#pragma mark - Database
#pragma mark

/*
 ** Retrieve all tasks from database if their modification type is not set to "delete"
 */
-(void)retrieveData
{
    self.listArray = [NSMutableArray array];

    [Appdelegate.database open];
    
    FMResultSet *resultSet=[Appdelegate.database executeQuery:@"SELECT * FROM List WHERE ModificationType <> 'Delete'"];
    if(resultSet)
    {
        NSArray *keys, *values;
        NSMutableDictionary *list;
        
        while([resultSet next])
        {
            keys = [[resultSet resultDictionary] allKeys];
            values = [[resultSet resultDictionary] allValues];
            list = [NSMutableDictionary dictionary];
            
            for (int j=0; j<[values count];j++)
            {
                [list setObject:[values objectAtIndex:j] forKey:[keys objectAtIndex:j]];
            }
            [self.listArray addObject:list];
        }
    }
    
    // sort list array according the date of the task
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"OrderId"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    self.listArray = [NSMutableArray arrayWithArray:[self.listArray sortedArrayUsingDescriptors:sortDescriptors]];

    [Appdelegate.database close];
    
    [self.list_table reloadData];
}

/*
 ** Populate the database with all the tasks added
 */
-(void)insertTask:(NSDictionary *)listArray
{
    [Appdelegate.database open];
    
    BOOL isInserted = [Appdelegate.database executeUpdate:@"INSERT INTO List (ListId, ListTitle, ListDate, ModifiedOn, ModificationType, OrderId) VALUES (?,?,?,?,?,?)", [listArray objectForKey:@"ListId"], [listArray objectForKey:@"ListTitle"], [listArray objectForKey:@"ListDate"], [listArray objectForKey:@"ModifiedOn"], [listArray objectForKey:@"ModificationType"], [listArray objectForKey:@"OrderId"]];
    [Appdelegate.database close];
    
    if(isInserted)
    {
        [self.listArray replaceObjectAtIndex:0 withObject:listArray];
        
        NSSortDescriptor *sortDescriptor;
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"OrderId"
                                                     ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        self.listArray = [NSMutableArray arrayWithArray:[self.listArray sortedArrayUsingDescriptors:sortDescriptors]];
        [self.list_table reloadData];
        NSLog(@"Task Inserted Successfully");
    }
    else
        NSLog(@"Error occured while inserting");
    
}

/*
 ** Update the database/row with the object modified
 */
-(void)updateTask:(NSDictionary *)listArray indexPath:(NSIndexPath *) indexPath
{
    NSInteger index = indexPath.row;
    
    [Appdelegate.database open];
    
    BOOL isUpdated = [Appdelegate.database executeUpdate:@"UPDATE List SET ListTitle =?, ListDate =?, ModificationType = ?, ModifiedOn = ?, OrderId = ? WHERE ListId =?", [listArray objectForKey:@"ListTitle"], [listArray objectForKey:@"ListDate"], [listArray objectForKey:@"ModificationType"],[self.dateFormatter stringFromDate:[NSDate date]], [listArray objectForKey:@"OrderId"],[listArray objectForKey:@"ListId"]];
    
    [Appdelegate.database close];
    
    if(isUpdated)
    {
        [self.listArray replaceObjectAtIndex:index withObject:listArray];
//        [self.list_table reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        NSLog(@"Task Updated Successfully");
    }else
        NSLog(@"Error occured while updating");
}

/*
 ** Remove object from database
 */
-(void)deleteList:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.row;
    
    [Appdelegate.database open];
    
    BOOL isDeleted = [Appdelegate.database executeUpdate:@"DELETE FROM List WHERE ListId = ?", [[self.listArray objectAtIndex:index] objectForKey:@"ListId"]];
    
    [Appdelegate.database close];
    
    if(isDeleted)
    {
        [self.listArray removeObjectAtIndex:index];
        [self.list_table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSLog(@"Task Deleted Successfully");
    }
    else
        NSLog(@"Error occured while deleting");
}

#pragma mark - CustomTableViewCellDelegate

/*
 ** Handle completed button selection: display the done button, and strikethrough the text if completed; get the task back to normal if not
 */
-(void)checkButtonSelected:(ListCell *)cell atIndex:(NSInteger)index selected:(BOOL)selected
{
    NSMutableDictionary *rowData;
    
    if (index == [self.listArray count])
    {
        rowData = self.listArray[index-1];
    }
    else
    {
        rowData = self.listArray[index];
    }
    
    if (selected == YES)
    {
        [cell.check_btn setImage:[UIImage imageNamed:@"Done_btn"] forState:UIControlStateNormal];

        NSString *titleStr= [rowData objectForKey:@"ListTitle"];
        NSMutableAttributedString *attribute_titleStr = [[NSMutableAttributedString alloc] initWithString:titleStr];
        
        [attribute_titleStr addAttributes:@{ NSStrikethroughStyleAttributeName : @(1), NSFontAttributeName :
                                           [FontManager bookFontOfSize:15] } range:NSMakeRange(0, titleStr.length)];
        
        [cell.todo_title setAttributedText:attribute_titleStr];
        
        NSString *dateStr= [rowData objectForKey:@"ListDate"];
        NSMutableAttributedString *attribute_dateStr = [[NSMutableAttributedString alloc] initWithString:dateStr];
        
        [attribute_dateStr addAttributes:@{ NSStrikethroughStyleAttributeName : @(1), NSFontAttributeName :
                                            [FontManager bookFontOfSize:12] } range:NSMakeRange(0, dateStr.length)];
        
        [cell.todo_date setAttributedText:attribute_dateStr];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if (![[[rowData objectForKey:@"ModificationType"] lowercaseString] isEqualToString:[@"Completed" lowercaseString]])
        {
            [rowData removeObjectForKey:@"ModificationType"];
            [rowData setObject:@"Completed" forKey:@"ModificationType"];
            [self updateTask:rowData indexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
    else if (selected == NO)
    {
        [cell.check_btn setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];

        [cell.todo_title setText:[rowData objectForKey:@"ListTitle"]];
        [cell.todo_date setText:[rowData objectForKey:@"ListDate"]];
        [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
        
        if (![[[rowData objectForKey:@"ModificationType"] lowercaseString] isEqualToString:[@"Update" lowercaseString]])
        {
            [rowData removeObjectForKey:@"ModificationType"];
            [rowData setObject:@"Update" forKey:@"ModificationType"];
            [self updateTask:rowData indexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        }
    }
}


/*
 ** Perform the delete button action: check first with user before proceeding with the removal
 */
-(void) deleteButtonSelected:(DatePickerCell *)cell atIndex:(NSInteger)index
{
    UIAlertView_Blocks *alert = [[UIAlertView_Blocks alloc] initWithTitle:@"Alert" message:@"Are you sure you want to delete this task?" cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes"]];
    alert.completion = ^(BOOL cancelled, NSInteger buttonIndex) {
        if (!cancelled) {
            [self close:nil]; // make sure the cell is closed before removing it
            [self deleteList:[NSIndexPath indexPathForRow:index inSection:0]]; // remove the object/row from database
        }
    };
    [alert show];
}

#pragma mark - Table View Delegates
#pragma mark

/*
 ** Checks and returns the selected indexpath if not empty
 */
-(BOOL)hasInlineExtendingCell {
    return (self.selectedIndexPath != nil);
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = [self.listArray count];
    // if selected indexpath is not empty, we need to dispaly the date picker in an inline cell; therefore we need to add a row below the selected row and increase the number of rows in the table
    if ([self hasInlineExtendingCell])
        numberOfRows += 1;
    
    return numberOfRows;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat heightForRow = 85;
    
    if (self.selectedIndexPath && self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row - 1) {
        // The inline pickerView is always the one after the selected normal cell
        heightForRow = 240.0f;
    }
    
    return heightForRow;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger dataRow = indexPath.row;

    if (self.selectedIndexPath && self.selectedIndexPath.section == indexPath.section && indexPath.row > self.selectedIndexPath.row)
        dataRow -= 1;

    NSDictionary *rowData = self.listArray[dataRow];
    DatePickerCell *datePickerViewCell;
    
    //  We always put the inline cell under the selected cell
    if (self.selectedIndexPath && self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == (indexPath.row - 1))
    {
        datePickerViewCell = [tableView dequeueReusableCellWithIdentifier:@"DatePickerViewCell"];
        [datePickerViewCell setBackgroundColor:[ColorTheme grey_bcg]];
        [datePickerViewCell.deleteTask setTag:indexPath.row];
        [datePickerViewCell setDelegate:self];
        [datePickerViewCell setSelected:NO];
        [datePickerViewCell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([self respondsToSelector:@selector(targetForAction:withSender:)]) // iOS 7 and above
        {
            if ([datePickerViewCell.datePicker targetForAction:@selector(handleDatePickerValueChanged:) withSender:datePickerViewCell.datePicker] == nil)
                [datePickerViewCell.datePicker addTarget:self action:@selector(handleDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
        }
        else // below iOS 7
            [datePickerViewCell.datePicker addTarget:self action:@selector(handleDatePickerValueChanged:) forControlEvents:UIControlEventValueChanged];

        if ([[rowData objectForKey:@"ListDate"] length] > 0)
            [datePickerViewCell.datePicker setDate:[self.dateFormatter dateFromString:[rowData objectForKey:@"ListDate"]] animated:YES];
    
        return datePickerViewCell;
    }

    
    ListCell *cell = (ListCell *)[tableView dequeueReusableCellWithIdentifier:@"listcell"];
    cell.delegate = self;
    
    if (cell != nil)
    {
        [cell setBackgroundColor:[ColorTheme grey_bcg]];

        [cell.todo_title setDelegate:self];
        [cell.check_btn setTag:indexPath.row];

        if (self.selectedIndexPath.row == dataRow && self.isOpen == YES)
        {
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            [cell.todo_title becomeFirstResponder];
            [cell.check_btn setHidden:YES];
            [cell.todo_title setUserInteractionEnabled:YES];

            if (self.dateUpdated == nil)
            {
                if ([[rowData objectForKey:@"ListDate"] length] > 0)
                    [cell.todo_date setText:[rowData objectForKey:@"ListDate"]];
                else
                    [cell.todo_date setText:[self.dateFormatter stringFromDate:[NSDate date]]];
            }
            else
                [cell.todo_date setText:[self.dateFormatter stringFromDate:self.dateUpdated]];
          
            if ([[rowData objectForKey:@"ListTitle"] length] > 0)
                [cell.todo_title setText:[rowData objectForKey:@"ListTitle"]];
            else if ([self.titleUpdate length] > 0)
                [cell.todo_title setText:self.titleUpdate];
            else
                [cell.todo_title setText:@""];
        }
        else
        {
            [cell.todo_title setUserInteractionEnabled:NO];
            [cell.check_btn setHidden:NO];
            [cell.check_btn setImage:[UIImage imageNamed:@"Unchecked"] forState:UIControlStateNormal];

            [cell.todo_title setText:[rowData objectForKey:@"ListTitle"]];
            [cell.todo_date setText:[rowData objectForKey:@"ListDate"]];
            
            if ([[[rowData objectForKey:@"ModificationType"] lowercaseString] isEqualToString:[@"Completed" lowercaseString]])
                [self checkButtonSelected:cell atIndex:indexPath.row selected:YES];
            else
                [self checkButtonSelected:cell atIndex:indexPath.row selected:NO];
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    //// TODO: to be calculated ratio wise according to cell height - textview instead of textfield
    return 180.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *top_view = [[UIView alloc] init];
    [top_view setBackgroundColor:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:1]];
    
    UIView *inside_view = [[UIView alloc] init];
    [inside_view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [inside_view setBackgroundColor:[UIColor whiteColor]];
    [top_view addSubview:inside_view];
    
    UILabel *inside_text = [[UILabel alloc] init];
    [inside_text setTranslatesAutoresizingMaskIntoConstraints:NO];
    [inside_text setBackgroundColor:[UIColor clearColor]];
    [inside_text setTextAlignment:NSTextAlignmentLeft];
    [inside_text setTextColor:[ColorTheme blue]];
    [inside_text setFont:[FontManager bookFontOfSize:30]];

    NSString *textString, *daytimeString;
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit fromDate:[NSDate date]];
    NSInteger hour = [components hour];
    if (hour >= 0 && hour < 12)
        daytimeString = @"Good morning";
    else if(hour >= 12 && hour < 17)
        daytimeString = @"Good afternoon";
    else if(hour >= 17)
        daytimeString = @"Good evening";
    
    if ([self.userName length] >0)
        textString = [NSString stringWithFormat:@"%@ %@,\n\nlet's go through your tasks", daytimeString, [[self.userName componentsSeparatedByString:@" "] objectAtIndex:0]];
    else
        textString = [NSString stringWithFormat:@"%@,\n\nlet's go through your tasks", daytimeString];
    NSRange range = [textString rangeOfString:[NSString stringWithFormat:@"\nlet's go through your tasks"]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:textString];
    [attrString beginEditing];
    [attrString addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"Gotham-Light" size:18]
                       range:range];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor darkGrayColor]
                       range:range];
    [attrString endEditing];
    [inside_text setAttributedText:attrString];
    [inside_text setNumberOfLines:0];
    [inside_text setLineBreakMode:NSLineBreakByWordWrapping];
    [top_view addSubview:inside_text];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:top_view forKey:@"topv"];
    [dict setObject:inside_view forKey:@"insidev"];
    [dict setObject:inside_text forKey:@"insidet"];
    
    [top_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-10-[insidev]-10-|" options:0 metrics:nil views:dict]];
    [top_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-20-[insidev]-0-|" options:0 metrics:nil views:dict]];

    [top_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[insidet]-20-|" options:0 metrics:nil views:dict]];
    [top_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-40-[insidet]-10-|" options:0 metrics:nil views:dict]];

    return top_view;
}

/*
 ** The 2 below functions will "erase" the extra rows from the table view display
 */

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (self.selectedIndexPath)
        [self displayOrHideInlinePickerViewForIndexPath:self.selectedIndexPath];

}


-(void)reorderData:(NSNotification *)notif_dict
{
    NSDictionary *dictionary = [notif_dict userInfo];
    
    [Appdelegate.database open];
    
    BOOL isUpdated = [Appdelegate.database executeUpdate:@"UPDATE List SET OrderId = ? WHERE OrderId = ? and ListId = ?", [dictionary objectForKey:@"current"], [dictionary objectForKey:@"origin"],[[self.listArray objectAtIndex:[[dictionary objectForKey:@"origin"] integerValue]] objectForKey:@"ListId"]];

    BOOL isUpdated_origin = [Appdelegate.database executeUpdate:@"UPDATE List SET OrderId = ? WHERE OrderId = ? and ListId = ?", [dictionary objectForKey:@"origin"], [dictionary objectForKey:@"current"], [[self.listArray objectAtIndex:[[dictionary objectForKey:@"current"] integerValue]] objectForKey:@"ListId"]];

    [Appdelegate.database close];
    
        if(isUpdated && isUpdated_origin)
        {
            NSString *stringToMove = [self.listArray objectAtIndex:[[dictionary objectForKey:@"origin"] integerValue]];
            [self.listArray removeObjectAtIndex:[[dictionary objectForKey:@"origin"] integerValue]];
            [self.listArray insertObject:stringToMove atIndex:[[dictionary objectForKey:@"current"] integerValue]];
            
            NSLog(@"Task rerorder updated Successfully");
        }else
            NSLog(@"Error occured while reordering");
    
    [self.list_table reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
    NSInteger dataRow = indexPath.row;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (dataRow == self.selectedIndexPath.row || self.selectedIndexPath == nil) // don't allow other cells to be opened if one is already active
    {
        if (![[[[self.listArray objectAtIndex:indexPath.row] objectForKey:@"ModificationType"] lowercaseString] isEqualToString:[@"Completed" lowercaseString]])
        {
            if (self.selectedIndexPath == nil)
            {
                self.isNew = NO;
                [self displayOrHideInlinePickerViewForIndexPath:indexPath];

                [self.list_table scrollToRowAtIndexPath:indexPath
                                       atScrollPosition:UITableViewScrollPositionTop
                                               animated:YES];
            }
        }
    }
    else
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Show/Add picker under Row
#pragma mark

-(void)displayOrHideInlinePickerViewForIndexPath:(NSIndexPath *)indexPath {

    [self.list_table beginUpdates];
    
    if (self.selectedIndexPath == nil) {
        self.selectedIndexPath = indexPath;
        [self.list_table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section]]
                              withRowAnimation:UITableViewRowAnimationFade];
        
        self.isOpen = YES;
        
        [self.list_table reloadRowsAtIndexPaths:@[indexPath]
                               withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.list_table setScrollEnabled:NO];
        [self.plus_button setBackgroundImage:[UIImage imageNamed:@"Done_btn"] forState:UIControlStateNormal];
        [self.plus_button removeTarget:self action:@selector(plusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.plus_button addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if (self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row) {
    
        [self.list_table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:(indexPath.row + 1) inSection:indexPath.section]]
                              withRowAnimation:UITableViewRowAnimationFade];
        self.selectedIndexPath = nil;
        self.dateUpdated = nil;
        self.titleUpdate = nil;
        
        
        self.isOpen = NO;
        [self.list_table reloadRowsAtIndexPaths:@[indexPath]
                               withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.list_table setScrollEnabled:YES];

        [self.plus_button setBackgroundImage:[UIImage imageNamed:@"Add_btn"] forState:UIControlStateNormal];
        [self.plus_button removeTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
        [self.plus_button addTarget:self action:@selector(plusButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.list_table endUpdates];
}

#pragma mark - UITextField delegates
#pragma mark

/*
 ** Get the updated text from textfield
 */
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    self.titleUpdate = textField.text;

    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    self.titleUpdate = textField.text;
    [textField resignFirstResponder];
}

#pragma mark - Date Picker
#pragma mark

/*
 ** Get the date from picker when updated
 */
-(void)handleDatePickerValueChanged:(UIDatePicker *)datePicker {
   
    ListCell *cell = (ListCell *)[self.list_table cellForRowAtIndexPath:self.selectedIndexPath];

    [cell.todo_title resignFirstResponder];
    
    NSMutableDictionary *rowData = [self.listArray[self.selectedIndexPath.row] mutableCopy];
    self.listArray[self.selectedIndexPath.row] = rowData;
    self.dateUpdated = datePicker.date;
    
    [self.list_table reloadRowsAtIndexPaths:@[self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone]; // update the label in cell to the date changed
}


#pragma mark - Floating Button
#pragma mark

/*
 ** Plus button action: call add new task when plus button is pressed
 */
-(void)plusButtonPressed
{
    self.isNew = YES;
    self.isOpen = YES;

    // create a dummy empty task to display on the table
    NSMutableDictionary *test = [NSMutableDictionary dictionary];
    [test setObject:@"" forKey:@"ListTitle"];
    [test setObject:@"" forKey:@"ListDate"];
    [test setObject:[self.dateFormatter stringFromDate:[NSDate date]] forKey:@"ModifiedOn"];
    [test setObject:@"Insert" forKey:@"ModificationType"];
    [self.listArray insertObject:test atIndex:0];
    
    [self.list_table beginUpdates];
    [self.list_table insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.list_table endUpdates];
    
    [self.list_table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
    if (self.selectedIndexPath)
        [self displayOrHideInlinePickerViewForIndexPath:self.selectedIndexPath];
    else
        [self displayOrHideInlinePickerViewForIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark - Close cell
#pragma mark

/*
 ** Function to save and/or close the opened cell
 */
-(IBAction)close:(id)sender
{
    ListCell *cell = (ListCell *)[self.list_table cellForRowAtIndexPath:self.selectedIndexPath];
    
    if ([sender tag] == 88) // if from done button : save and close the cell
    {
        // check if the task title is empty or not: user is not allowed to insert tasks with no title/body
        if ([self.titleUpdate length] >0 || cell.todo_title.text.length >0)
        {
            NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
            [elementDict setObject:[self.titleUpdate length] > 0 ? self.titleUpdate : [[self.listArray objectAtIndex:self.selectedIndexPath.row] objectForKey:@"ListTitle"] forKey:@"ListTitle"];
            if (self.isNew == YES)
                [elementDict setObject:self.dateUpdated == nil ? [self.dateFormatter stringFromDate:[NSDate date]] : [self.dateFormatter stringFromDate:self.dateUpdated] forKey:@"ListDate"];
            else
                [elementDict setObject:self.dateUpdated == nil ? [[self.listArray objectAtIndex:self.selectedIndexPath.row] objectForKey:@"ListDate"] : [self.dateFormatter stringFromDate:self.dateUpdated] forKey:@"ListDate"];
            [elementDict setObject:[self.dateFormatter stringFromDate:[NSDate date]] forKey:@"ModifiedOn"];

            if (self.isNew == YES)
            {
                // Retrieve the biggest ID in the List table, if there is no id then set the list id is set to 0; else if an id exists, check if the id is  not null or of negative value then increment the maximum value retrieved by 1
                
                [elementDict setObject:@"Insert" forKey:@"ModificationType"];
                [Appdelegate.database open];
                int listId = 0;
                int orderId = 0;
                
                FMResultSet *resultSet=[Appdelegate.database executeQuery:@"SELECT MAX(ListId) AS MAX FROM List"];
                if(resultSet)
                {
                    while([resultSet next])
                    {
                        if ([[resultSet resultDictionary] objectForKey:@"MAX"] != [NSNull null])
                        {
                            listId = [[[resultSet resultDictionary] objectForKey:@"MAX"] intValue] + 1;
                        }
                        else
                            listId = 0;
                    }
                }

                FMResultSet *resultSet_order=[Appdelegate.database executeQuery:@"SELECT MAX(OrderId) AS MAX FROM List"];
                if(resultSet_order)
                {
                    while([resultSet_order next])
                    {
                        if ([[resultSet_order resultDictionary] objectForKey:@"MAX"] != [NSNull null])
                        {
                            orderId = [[[resultSet_order resultDictionary] objectForKey:@"MAX"] intValue] + 1;
                        }
                        else
                            orderId = 0;
                    }
                }

                [Appdelegate.database close];
                
                [elementDict setObject:[NSNumber numberWithInt:listId] forKey:@"ListId"];
                [elementDict setObject:[NSNumber numberWithInt:orderId] forKey:@"OrderId"];
                
                [self insertTask:elementDict];
            }
            else
            {
                [elementDict setObject:[[self.listArray objectAtIndex:self.selectedIndexPath.row] objectForKey:@"ListId"] forKey:@"ListId"];
                [elementDict setObject:[[self.listArray objectAtIndex:self.selectedIndexPath.row] objectForKey:@"OrderId"] forKey:@"OrderId"];
                [elementDict setObject:@"Update" forKey:@"ModificationType"];
                [self updateTask:elementDict indexPath:self.selectedIndexPath];
            }

            // close the opened cell
            if (self.selectedIndexPath)
                [self displayOrHideInlinePickerViewForIndexPath:self.selectedIndexPath];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"You can't add an empty task!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else // close the opened cell if any
    {
        if (self.selectedIndexPath)
            [self displayOrHideInlinePickerViewForIndexPath:self.selectedIndexPath];
    }
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
