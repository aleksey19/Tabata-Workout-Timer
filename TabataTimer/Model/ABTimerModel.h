//
//  ABTimerModel.h
//  TabataTimer
//
//  Created by Alexey Bidnyk on 30.09.16.
//  Copyright © 2016 Alexey Bidnyk. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSInteger const REFRESH_INTERVAL;

@interface ABTimerModel : NSObject

@property (nonatomic, strong) NSString *prepareTitle;
@property (nonatomic, strong) NSString *workTitle;
@property (nonatomic, strong) NSString *restTitle;

@property (nonatomic, strong) NSNumber *currentLap;
@property (nonatomic, strong) NSNumber *countOfLaps;
@property (nonatomic, readonly) NSTimeInterval totalPrepareTime;
@property (nonatomic, readonly) NSTimeInterval totalWorkTime;
@property (nonatomic, readonly) NSTimeInterval totalRestTime;
@property (nonatomic) NSTimeInterval elapsedTime;

@property (nonatomic, readonly) BOOL mute;

@property (nonatomic, readonly) BOOL timerDidStart;
@property (nonatomic, readonly) BOOL timerOnPause;
@property (nonatomic, readonly) BOOL timerOnPrepare;
@property (nonatomic, readonly) BOOL timerOnWorkout;
@property (nonatomic, readonly) BOOL timerOnRest;

@property (nonatomic, strong, readonly) UIColor *circleColor;
@property (nonatomic, strong, readonly) UIColor *elapsedTimeColor;

- (void)setMute:(BOOL)mute;
- (void)setTimerDidStart:(BOOL)timerDidStart;
- (void)setTimerOnPause:(BOOL)timerOnPause;

- (NSNumber *)valideLapsCount:(NSNumber *)lapsCount;
- (NSTimeInterval)valideTimeInterval:(NSTimeInterval)timeInterval;

- (void)startPrepareTimer;
- (void)startWorkoutTimer;
- (void)startRestTimer;

- (void)resumeTimer;
- (void)stopTimer;

- (void)prepareForWorkoutCountDown;

- (void)clearModelData;

@end
