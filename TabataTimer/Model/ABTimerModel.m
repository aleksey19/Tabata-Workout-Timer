//
//  ABTimerModel.m
//  TabataTimer
//
//  Created by Alexey Bidnyk on 30.09.16.
//  Copyright © 2016 Alexey Bidnyk. All rights reserved.
//

#import "ABTimerModel.h"

#import <ReactiveCocoa/ReactiveCocoa.h>
//#import <AVFoundation/AVAudioPlayer.h>
#import <AudioToolbox/AudioToolbox.h>

#import "UIColor+ABTabataTimerColors.h"

NSInteger const REFRESH_INTERVAL = 1.0;

@interface ABTimerModel ()

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, readwrite) BOOL timerDidStart;
@property (nonatomic, readwrite) BOOL timerOnPause;
@property (nonatomic, readwrite) BOOL timerOnPrepare;
@property (nonatomic, readwrite) BOOL timerOnWorkout;
@property (nonatomic, readwrite) BOOL timerOnRest;

@end

@implementation ABTimerModel

#pragma mark - Setters

- (void)setMute:(BOOL)mute {
    _mute = mute;
}

- (void)setTimerDidStart:(BOOL)timerDidStart {
    _timerDidStart = timerDidStart;
}

- (void)setTimerOnPause:(BOOL)timerOnPause {
    _timerOnPause = timerOnPause;
}

- (void)setCircleColor:(UIColor *)circleColor {
    _circleColor = circleColor;
}

#pragma mark - Initializer

- (instancetype)init {
    if (self = [super init]) {
        [self setDefaultValues];
    }
    return self;
}

- (void)setDefaultValues {
    _countOfLaps = @(1);
    _currentLap = @(0);
    _totalPrepareTime = 0;
    _totalWorkTime = 0;
    _totalRestTime = 0;
    _elapsedTime = _totalPrepareTime;
    
    _mute = NO;
    _timerDidStart = NO;
    _timerOnPause = NO;
    
    _elapsedTimeColor = nil;
    
    _circleColor = [UIColor aquaColor];
}

#pragma mark - Validation

- (NSNumber *)valideLapsCount:(NSNumber *)lapsCount {
    return [lapsCount integerValue] < 100 ? lapsCount : @0;
}

- (NSTimeInterval)valideTimeInterval:(NSTimeInterval)timeInterval {
    return timeInterval < 600.0f ? timeInterval : 0.0f;
}

#pragma mark - Timer logic

- (void)startPrepareTimer {
    if (self.timerDidStart) { return ;}
    
    self.circleColor = [UIColor aquaColor];
    self.elapsedTime = self.totalPrepareTime;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL
                                                  target:self
                                                selector:@selector(countDownPrepareTime)
                                                userInfo:nil
                                                 repeats:YES];
    self.timerOnPrepare = YES;
    self.timerDidStart = YES;
    self.timerOnPause = NO;
    
}

- (void)prepareForWorkoutCountDown {
    self.currentLap = @(self.currentLap.integerValue + 1);
    self.elapsedTime = self.totalWorkTime;
    self.circleColor = [UIColor brightRedColor];
    self.timerOnWorkout = YES;
}

- (void)startWorkoutTimer {
    if (!self.timerDidStart) { return ;}
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL
                                                  target:self
                                                selector:@selector(countDownWorkoutTime)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)prepareForRestCountDown {
    self.elapsedTime = self.totalRestTime;
    self.circleColor = [UIColor softGreenColor];
    self.timerOnRest = YES;
}

- (void)startRestTimer {
    if (!self.timerDidStart) { return ;}
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:REFRESH_INTERVAL
                                                  target:self
                                                selector:@selector(countDownRestTime)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)countDownPrepareTime {
    if (3 >= self.elapsedTime > 0) {
        [self playSound];
    }
    if (--self.elapsedTime == 0) {
        // prepare timer elapsed
        if (self.timerOnPrepare) {
            self.timerOnPrepare = NO;
            [self.timer invalidate];
            [self performSelector:@selector(prepareForWorkoutCountDown)
                       withObject:nil
                       afterDelay:REFRESH_INTERVAL];
        }                        
    }
    NSLog(@"%f", self.elapsedTime);
}

- (void)countDownWorkoutTime {
    if (--self.elapsedTime == 0) {
        if (self.timerOnWorkout) {
            self.timerOnWorkout = NO;
            [self.timer invalidate];
            if (self.currentLap.integerValue == self.countOfLaps.integerValue) {
                [self clearModelData];
            } else {
                [self performSelector:@selector(prepareForRestCountDown)
                           withObject:nil
                           afterDelay:REFRESH_INTERVAL];
            }
        }
    }
}

- (void)countDownRestTime {
    if (--self.elapsedTime == 0) {
        if (self.timerOnRest) {
            self.timerOnRest = NO;
            [self.timer invalidate];
            [self performSelector:@selector(prepareForWorkoutCountDown)
                       withObject:nil
                       afterDelay:REFRESH_INTERVAL];
        }
    }
}

- (void)resumeTimer {
    [self.timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    [self.timer fire];
    self.elapsedTime++;
    self.timerOnPause = NO;
}

- (void)stopTimer {
    if (!self.timerDidStart) { return; }
    
    [self.timer setFireDate:[NSDate distantFuture]];
    self.timerOnPause = YES;
}

- (void)playSound {
//    NSURL* musicFile = [NSURL initFileURLWithPath:[[NSBundle mainBundle]
//                                                   pathForResource:@"BubblePopv4"
//                                                   ofType:@"mp3"]];

//    NSString *fileURLString = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] resourcePath]];
//    NSString *fileNameWithExtension = @"Beep.mp3";
//    NSURL *fileURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", fileURLString, fileNameWithExtension]];
//    NSError *error = nil;
//    
//    AVAudioPlayer *audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:&error];
    
//    NSString *path = [[NSBundle bundleWithIdentifier:@"com.apple.UIKit"] pathForResource:@"Tock" ofType:@"aiff"];
//    SystemSoundID soundID;
//    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &soundID);
//    AudioServicesPlaySystemSound(soundID);
//    AudioServicesDisposeSystemSoundID(soundID);

    NSURL *fileURL = [NSURL URLWithString:@"/System/Library/Audio/UISounds/ReceivedMessage.caf"]; // see list below
    SystemSoundID soundID = 1005;
    AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)fileURL,&soundID);
    AudioServicesPlaySystemSound(soundID);
}

#pragma mark - Clear model

- (void)clearModelData {
    [self setDefaultValues];
}

@end
