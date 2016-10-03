//
//  ABTabataTimerView.h
//  TabataTimer
//
//  Created by Alexey Bidnyk on 28.09.16.
//  Copyright © 2016 Alexey Bidnyk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ABTimerModel;

IB_DESIGNABLE @interface ABTabataTimerView : UIView

@property (nonatomic, strong, readonly) IBInspectable UIColor *remainedTimeColor;
@property (nonatomic, strong, readonly) IBInspectable UIColor *elapsedTimeColor;

@property (nonatomic, readonly) IBInspectable NSUInteger thickness;

- (void)setModel:(ABTimerModel *)model;

- (void)startTimer;
- (void)stopTimer;
- (void)resumeTimer;

- (void)handlePauseAction;

@end
