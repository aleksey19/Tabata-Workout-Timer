//
//  ABTimerViewController.h
//  TabataTimer
//
//  Created by Alexey Bidnyk on 27.09.16.
//  Copyright © 2016 Alexey Bidnyk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ABTimerModel;
@class ABPrepareTimerModel;
@class ABWorkTimerModel;
@class ABRestTimerModel;

@interface ABTimerViewController : UIViewController

@property (weak, nonatomic) ABTimerModel *timerModel;

@end
