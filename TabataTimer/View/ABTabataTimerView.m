//
//  ABTabataTimerView.m
//  TabataTimer
//
//  Created by Alexey Bidnyk on 28.09.16.
//  Copyright © 2016 Alexey Bidnyk. All rights reserved.
//

#import "ABTabataTimerView.h"

#import "ABTimerModel.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "AppDelegate.h"

@interface ABTabataTimerView ()

@property (nonatomic, strong) ABTimerModel *model;

@property (nonatomic, strong) IBOutlet UILabel *elapsedTimeLabel;
@property (nonatomic) CGFloat startAngle;

@end

@implementation ABTabataTimerView

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    self.startAngle = - M_PI_2;
    CGFloat endAngle = 2 * M_PI + self.startAngle;
    
    [self drawCircleInRect:rect
            withStartAngle:self.startAngle
                  endAngle:endAngle
                     color:self.model.circleColor.CGColor
                 animation:nil];
}

- (void)drawCircleInRect:(CGRect)rect
          withStartAngle:(CGFloat)startAngle
                endAngle:(CGFloat)endAngle
                   color:(CGColorRef)cgColor
               animation:(CAAnimation *)animation {
    CGFloat halfRectWidth = CGRectGetWidth(rect) / 2;
    CGFloat radius = halfRectWidth - self.thickness;
    
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath addArcWithCenter:CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
                          radius:radius
                      startAngle:startAngle
                        endAngle:endAngle
                       clockwise:YES];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    [shapeLayer setPath:bezierPath.CGPath];
    [shapeLayer setStrokeColor:cgColor];
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    [shapeLayer setLineWidth:self.thickness];
    [shapeLayer addAnimation:animation forKey:@"strokeEnd"];
    
    [self.layer addSublayer:shapeLayer];
}

- (void)drawCircleFragmentForTotalTime:(NSTimeInterval)totalTime {
    CGFloat anglePerSecond = ((1.0 / totalTime) * 2 * M_PI);
    CGFloat endAngle = self.startAngle + anglePerSecond;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = 1.0;
    animation.fromValue = @(0.0);
    animation.toValue = @(1.0);
    animation.removedOnCompletion = YES;

    [self drawCircleInRect:self.bounds
            withStartAngle:self.startAngle
                  endAngle:endAngle
                     color:[UIColor lightGrayColor].CGColor
                 animation:animation];
    
    self.startAngle = endAngle;
}

#pragma mark - Model binding

- (void)bindModel {    
    RAC(self, elapsedTimeLabel.text) = [RACObserve(self.model, elapsedTime) map:^id(NSNumber *elapsedTime) {
        if (self.model.timerDidStart && !self.model.timerOnPause) {
            if (self.model.timerOnPrepare) {
                [self drawCircleFragmentForTotalTime:self.model.totalPrepareTime];
            } else if (self.model.timerOnWorkout) {
                [self drawCircleFragmentForTotalTime:self.model.totalWorkTime];
            } else if (self.model.timerOnRest) {
                [self drawCircleFragmentForTotalTime:self.model.totalRestTime];
            }
            [self checkElapsedTime:elapsedTime.floatValue];
        }
        return [NSString stringWithFormat:@"%@", elapsedTime];
    }];
    [RACObserve(self.model, timerOnWorkout) subscribeNext:^(NSNumber *timerOnWorkout) {
        if (timerOnWorkout.boolValue) {
            [self redrawCircleForNextCountDown];
            [self.model startWorkoutTimer];
        }
    }];
    [RACObserve(self.model, timerOnRest) subscribeNext:^(NSNumber *timerOnRest) {
        if (timerOnRest.boolValue) {
            [self redrawCircleForNextCountDown];
            [self.model startRestTimer];
        }
    }];
}

#pragma mark - Model setter

- (void)setModel:(ABTimerModel *)model {
    _model = model;
    [self bindModel];
}

#pragma mark - Timer actions

- (void)startTimer {
    [self.model startPrepareTimer];
}

- (void)stopTimer {
    [self.model stopTimer];
}

- (void)resumeTimer {
    [self.model resumeTimer];
}

- (void)handlePauseAction {
    self.model.timerOnPause ? [self resumeTimer] : [self stopTimer];
}

#pragma mark - Misc

- (void)checkElapsedTime:(NSTimeInterval)elapsedTime {
    if (elapsedTime == 0 && self.model.countOfLaps.integerValue == self.model.currentLap.integerValue) {
        if ([self.model isMemberOfClass:[ABTimerModel class]]) {
            self.model.timerDidStart = NO;
            [self performSelector:@selector(popToRootViewController) withObject:nil afterDelay:REFRESH_INTERVAL * 2];
        }
    }
}

- (void)popToRootViewController {
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate);
    UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;
    [navigationController popToRootViewControllerAnimated:YES];
}

- (void)redrawCircleForNextCountDown {
    [self drawRect:self.bounds];
}

#pragma mark - IBInspectable

- (void)prepareForInterfaceBuilder {
    [super prepareForInterfaceBuilder];
    
    CGRect rect = self.bounds;
    [self drawRect:rect];
}

@end
