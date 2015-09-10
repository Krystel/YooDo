//
//  FirstPage.m
//  Tictail
//
//  Created by Krystel Chaccour on 9/9/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

#import "WelcomePage.h"
#import "MainPage.h"
#import "DMScaleTransition.h"

@interface WelcomePage () <UITextFieldDelegate, UITextViewDelegate, UIViewControllerTransitioningDelegate>
{
    IQKeyboardReturnKeyHandler *returnHandler;
    UITextField *name_field;
    UIButton *submit_btn;
}
@property (nonatomic, strong) DMScaleTransition *scaleTransition;
@property (nonatomic, strong) NSString *userName;

@end

@implementation WelcomePage

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // Handle keyboard: next, previous behavior and resign/dismiss
    returnHandler = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    [returnHandler setDelegate:self];
    [returnHandler setToolbarManageBehaviour:IQAutoToolbarByPosition];
    [returnHandler setLastTextFieldReturnKeyType:UIReturnKeyDone];
    
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:YES];
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];

    UIImageView *background_image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Example1"]];
    [background_image setTranslatesAutoresizingMaskIntoConstraints:NO];
    [background_image setContentMode:UIViewContentModeScaleAspectFill];
    [background_image setBackgroundColor:[UIColor clearColor]];
    [background_image setUserInteractionEnabled:YES];
    [self.view addSubview:background_image];

    CSAnimationView *animate_text = [CSAnimationView new];
    [animate_text setTranslatesAutoresizingMaskIntoConstraints:NO];
    [animate_text setBackgroundColor:[UIColor clearColor]];
    [animate_text setType:CSAnimationTypeFadeIn];
    [animate_text setDelay:0.2];
    [animate_text setDuration:1.0];
    [animate_text setUserInteractionEnabled:YES];
    [background_image addSubview:animate_text];

    UILabel *page_title = [[UILabel alloc] init];
    [page_title setTranslatesAutoresizingMaskIntoConstraints:NO];
    [page_title setTextColor:[UIColor whiteColor]];
    [page_title setBackgroundColor:[UIColor clearColor]];
    [page_title setFont:[FontManager lightFontOfSize:14]];
    NSString *textString = [NSString stringWithFormat:@"Welcome !\n\n\n\nI'm Yoodo the to-do app that let's you kickoff your day in the most organized way.\n\n\nLet's be friends!"];
    NSRange range = [textString rangeOfString:[NSString stringWithFormat:@"Welcome !"]];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:textString];
    [attrString beginEditing];
    [attrString addAttribute:NSFontAttributeName
                       value:[FontManager bookFontOfSize:30]
                       range:range];
    [attrString addAttribute:NSForegroundColorAttributeName
                       value:[UIColor whiteColor]
                       range:range];
    [attrString endEditing];
    [page_title setAttributedText:attrString];
    [page_title setTextAlignment:NSTextAlignmentCenter];
    [page_title setNumberOfLines:0];
    [page_title setLineBreakMode:NSLineBreakByWordWrapping];
    [animate_text addSubview:page_title];
    
    UIView *field_view = [[UIView alloc] init];
    [field_view setTranslatesAutoresizingMaskIntoConstraints:NO];
    [field_view setBackgroundColor:[UIColor colorWithRed:0.592 green:0.631 blue:0.573 alpha:0.6]];
    [field_view setUserInteractionEnabled:YES];
    [animate_text addSubview:field_view];
    [animate_text bringSubviewToFront:field_view];

    name_field = [[UITextField alloc] init];
    [name_field setTranslatesAutoresizingMaskIntoConstraints:NO];
    [name_field setTextColor:[UIColor whiteColor]];
    [name_field setFont:[FontManager bookFontOfSize:16]];
    [name_field setBorderStyle:UITextBorderStyleNone];
    [name_field setTextAlignment:NSTextAlignmentCenter];
    [name_field setClearButtonMode:UITextFieldViewModeWhileEditing];
    [name_field setPlaceholder:@"Enter your name"];
    [name_field setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    [name_field setAutocorrectionType:UITextAutocorrectionTypeNo];
    [name_field setUserInteractionEnabled:YES];
    [name_field setDelegate:self];
    [name_field sizeToFit];
    [name_field layoutIfNeeded];
    [name_field addTarget:self action:@selector(catchFirstCharacter:) forControlEvents:UIControlEventEditingChanged];
    [field_view addSubview:name_field];
    [field_view bringSubviewToFront:name_field];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:name_field.placeholder];
    NSDictionary *attributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[FontManager lightFontOfSize:15]};
    [attributedString setAttributes:attributes range:NSMakeRange(0, [attributedString length])];
    [name_field setAttributedPlaceholder:attributedString];

    submit_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [submit_btn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [submit_btn setBackgroundColor:[UIColor colorWithRed:0.592 green:0.631 blue:0.573 alpha:0.6]];
    [submit_btn setUserInteractionEnabled:YES];
    [submit_btn setTag:10];
    [submit_btn addTarget:self action:@selector(saveName:) forControlEvents:UIControlEventTouchUpInside];
    [animate_text addSubview:submit_btn];
    [animate_text bringSubviewToFront:submit_btn];
    
    UIButton *check_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [check_btn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [check_btn setBackgroundImage:[UIImage imageNamed:@"Check"] forState:UIControlStateNormal];
    [check_btn setUserInteractionEnabled:YES];
    [check_btn setTag:10];
    [check_btn addTarget:self action:@selector(saveName:) forControlEvents:UIControlEventTouchUpInside];
    [submit_btn addSubview:check_btn];
    [submit_btn bringSubviewToFront:check_btn];

    UIButton *noName_btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [noName_btn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [noName_btn setBackgroundColor:[UIColor colorWithRed:0.933 green:0.933 blue:0.933 alpha:0.8]];
    [noName_btn setUserInteractionEnabled:YES];
    [noName_btn addTarget:self action:@selector(saveName:) forControlEvents:UIControlEventTouchUpInside];
    [noName_btn setTag:11];
    [animate_text addSubview:noName_btn];
    [animate_text bringSubviewToFront:noName_btn];

    UILabel *noName_txt = [[UILabel alloc] init];
    [noName_txt setTranslatesAutoresizingMaskIntoConstraints:NO];
    [noName_txt setText:@"Let's keep some distance"];
    [noName_txt setFont:[FontManager bookFontOfSize:16]];
    [noName_txt setTextAlignment:NSTextAlignmentCenter];
    [noName_txt setBackgroundColor:[UIColor clearColor]];
    [noName_txt setTextColor:[UIColor colorWithRed:0.592 green:0.631 blue:0.573 alpha:1.0]];
    [noName_btn addSubview:noName_txt];
    [noName_btn bringSubviewToFront:noName_txt];

    UIView *line1 = [[UIView alloc] init];
    [line1 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [line1 setBackgroundColor:[ColorTheme grey_bcg]];
    [animate_text addSubview:line1];

    UILabel *or_label = [[UILabel alloc] init];
    [or_label setTranslatesAutoresizingMaskIntoConstraints:NO];
    [or_label setText:@"Or"];
    [or_label setFont:[FontManager bookFontOfSize:14]];
    [or_label setTextAlignment:NSTextAlignmentCenter];
    [or_label setBackgroundColor:[UIColor clearColor]];
    [or_label setTextColor:[ColorTheme grey_bcg]];
    [or_label sizeToFit];
    [animate_text addSubview:or_label];
    
    UIView *line2 = [[UIView alloc] init];
    [line2 setTranslatesAutoresizingMaskIntoConstraints:NO];
    [line2 setBackgroundColor:[ColorTheme grey_bcg]];
    [animate_text addSubview:line2];

    [animate_text startCanvasAnimation];

    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setObject:background_image forKey:@"background"];
    [dict setObject:page_title forKey:@"title"];
    [dict setObject:animate_text forKey:@"animtext"];
    [dict setObject:name_field forKey:@"field"];
    [dict setObject:field_view forKey:@"fview"];
    [dict setObject:noName_btn forKey:@"namebtn"];
    [dict setObject:noName_txt forKey:@"nametxt"];
    [dict setObject:line1 forKey:@"line1"];
    [dict setObject:line2 forKey:@"line2"];
    [dict setObject:or_label forKey:@"or"];
    [dict setObject:submit_btn forKey:@"submit"];
    [dict setObject:check_btn forKey:@"check"];
    int lineWidth = (([[UIScreen mainScreen] bounds].size.width - 60) / 2) - 20; //60 10 10 // 20
    [dict setObject:[NSNumber numberWithInt:lineWidth] forKey:@"lineWidth"];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[background]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[background]-0-|" options:0 metrics:nil views:dict]];
    
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[title]-30-|" options:0 metrics:nil views:dict]];
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-70-[title]" options:0 metrics:nil views:dict]];

    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[namebtn]-30-|" options:0 metrics:nil views:dict]];
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[namebtn(45)]-50-|" options:0 metrics:nil views:dict]];
    
    [noName_btn addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[nametxt]-5-|" options:0 metrics:nil views:dict]];
    [noName_btn addConstraint:[NSLayoutConstraint constraintWithItem:noName_txt attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:noName_btn attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[line1(==lineWidth)]" options:0 metrics:dict views:dict]];
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[line1(2)]-15-[namebtn]" options:0 metrics:nil views:dict]];

    [animate_text addConstraint:[NSLayoutConstraint constraintWithItem:or_label attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:animate_text attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [animate_text addConstraint:[NSLayoutConstraint constraintWithItem:or_label attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:line1 attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[line2(==lineWidth)]-30-|" options:0 metrics:dict views:dict]];
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[line2(2)]-15-[namebtn]" options:0 metrics:nil views:dict]];

    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[submit(55)]-30-|" options:0 metrics:nil views:dict]];
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[submit(45)]-15-[line1]" options:0 metrics:nil views:dict]];

    [submit_btn addConstraint:[NSLayoutConstraint constraintWithItem:check_btn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:submit_btn attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [submit_btn addConstraint:[NSLayoutConstraint constraintWithItem:check_btn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:submit_btn attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-30-[fview]-5-[submit]" options:0 metrics:nil views:dict]];
    [animate_text addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[fview(45)]-15-[line1]" options:0 metrics:nil views:dict]];

    [field_view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[field]-5-|" options:0 metrics:nil views:dict]];
    [field_view addConstraint:[NSLayoutConstraint constraintWithItem:name_field attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:field_view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];
    
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[animtext]-0-|" options:0 metrics:nil views:dict]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[animtext]-0-|" options:0 metrics:nil views:dict]];
}

#pragma mark - Save Name
#pragma mark

/*
 ** Handle whether user has chosen to share their name or remain anonymous
 */
-(IBAction)saveName:(id)sender
{
    if ([sender tag] == 10)
    {
        if ([self.userName length] > 0)
        {
            UIAlertView_Blocks *alert = [[UIAlertView_Blocks alloc] initWithTitle:@"Hold on" message:[NSString stringWithFormat:@"Are you sure you want us to call you\n%@", self.userName] cancelButtonTitle:@"Let's fix this" otherButtonTitles:@[@"Yep, that's me!"]];
            alert.completion = ^(BOOL cancelled, NSInteger buttonIndex) {
                if (!cancelled)
                    [self saveToPlist:self.userName];
            };
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops" message:@"Let's get to know each other first.\nDon't leave your name empty" delegate:nil cancelButtonTitle:@"Take me back" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    else if ([sender tag] == 11)
    {
        UIAlertView_Blocks *alert = [[UIAlertView_Blocks alloc] initWithTitle:@"Hold on" message:[NSString stringWithFormat:@"Are you sure you don't want to introduce yourself?"] cancelButtonTitle:@"No" otherButtonTitles:@[@"Yes!"]];
        alert.completion = ^(BOOL cancelled, NSInteger buttonIndex) {
            if (!cancelled)
                [self saveToPlist:@""];
        };
        [alert show];
    }
}

/*
 ** Save user's credentials in plist
 */
-(void)saveToPlist:(NSString *)user_name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0];
    NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"Credentials.plist"];
    
    NSDictionary *plistDict = [[NSDictionary alloc] initWithObjects:@[user_name] forKeys:[NSArray arrayWithObjects: @"UserName", nil]];
    
    NSString *error = nil;
    NSData *plistData = [NSPropertyListSerialization dataFromPropertyList:plistDict format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    
    if(plistData)
    {
        [plistData writeToFile:plistPath atomically:YES];
        [self goToMain];
        NSLog(@"Data saved sucessfully");
    }
    else
        NSLog(@"Data not saved");
}

/*
 ** Only display (send to main page) the first name not full name. Friends are on a first name basis right?
 */
-(void)catchFirstCharacter:(UITextField *)textField
{
    [submit_btn setBackgroundColor: [textField.text length] ? [UIColor colorWithRed:0.322 green:0.631 blue:0.773 alpha:0.6]: [UIColor colorWithRed:0.592 green:0.631 blue:0.573 alpha:0.6]];
    self.userName = textField.text;
}

#pragma mark - UITextField delegates
#pragma mark

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [submit_btn setBackgroundColor: [textField.text length] ? [UIColor colorWithRed:0.322 green:0.631 blue:0.773 alpha:0.6]: [UIColor colorWithRed:0.592 green:0.631 blue:0.573 alpha:0.6]];
    self.userName = textField.text;
    
    [textField resignFirstResponder];
}


-(BOOL)textFieldShouldClear:(UITextField *)textField
{
    [submit_btn setBackgroundColor: [UIColor colorWithRed:0.592 green:0.631 blue:0.573 alpha:0.6]];

    return YES;
}


#pragma mark - Go to Main
#pragma mark

/*
 ** Function to present controller in a custom way using scale transition
 */
-(void) goToMain
{
    self.scaleTransition = [[DMScaleTransition alloc]init];
    [self presentWithTransition:self.scaleTransition];
}

/*
 ** Present Task page with custom transition
 */
- (void)presentWithTransition:(id)transition
{
    MainPage *mainPage = [[MainPage alloc] init];
    mainPage.userName = [self.userName length] ? self.userName : @"";
    [mainPage setTransitioningDelegate:transition];
    
    [self presentViewController:mainPage animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
