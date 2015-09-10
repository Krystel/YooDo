//
//  MainPage.h
//  Tictail
//
//  Created by Krystel Chaccour on 9/4/15.
//  Copyright (c) 2015 Krystel Chaccour. All rights reserved.
//

@class LocalNotificationViewModel;
typedef void(^DoneBlock)(LocalNotificationViewModel *notification);

@interface MainPage : UIViewController
@property (nonatomic, retain) NSString *userName;
@property (copy, nonatomic) DoneBlock doneBlock;

@end
