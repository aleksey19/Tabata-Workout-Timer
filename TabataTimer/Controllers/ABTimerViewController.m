//
//  ABTimerViewController.m
//  TabataTimer
//
//  Created by Alexey Bidnyk on 27.09.16.
//  Copyright © 2016 Alexey Bidnyk. All rights reserved.
//

#import "ABTimerViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "ABTimerModel.h"

#import "ABTabataTimerView.h"

@class ABTabataTimerView;

@interface ABTimerViewController ()

@property (weak, nonatomic) IBOutlet ABTabataTimerView *tabataTimerView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundNumberLabel;

@property (weak, nonatomic) IBOutlet UIButton *pauseTimerButton;
@property (weak, nonatomic) IBOutlet UIButton *muteButton;

@end

@implementation ABTimerViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindViewWithModel:self.timerModel];
    [self.tabataTimerView startTimer];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES];
    self.roundNumberLabel.text = [NSString stringWithFormat:@"1/%@", self.timerModel.countOfLaps];
}

#pragma mark - Bind model

- (void)bindViewWithModel:(ABTimerModel *)model {
    [self.tabataTimerView setModel:model];
    self.titleLabel.text = model.prepareTitle;
    
    [RACObserve(model, timerOnPause) subscribeNext:^(NSNumber *pause) {
        UIImage *buttonBackgroundImage;
        pause.boolValue ? (buttonBackgroundImage = [UIImage imageNamed:@"play"]) : (buttonBackgroundImage = [UIImage imageNamed:@"pause"]);
        [self.pauseTimerButton setImage:buttonBackgroundImage forState:UIControlStateNormal];
    }];
    [RACObserve(model, mute) subscribeNext:^(NSNumber *mute) {
        UIImage *buttonBackgroundImage;
        mute.boolValue ? (buttonBackgroundImage = [UIImage imageNamed:@"mute"]) : (buttonBackgroundImage = [UIImage imageNamed:@"on"]);
        [self.muteButton setImage:buttonBackgroundImage forState:UIControlStateNormal];
    }];
    [RACObserve(model, timerOnPrepare) subscribeNext:^(NSNumber *onPrepare) {
        if (onPrepare.boolValue) {
            self.titleLabel.text = model.prepareTitle;
        }
    }];
    [RACObserve(model, timerOnWorkout) subscribeNext:^(NSNumber *onWorkout) {
        if (onWorkout.boolValue) {
            self.titleLabel.text = model.workTitle;
        }
    }];
    [RACObserve(model, timerOnRest) subscribeNext:^(NSNumber *onRest) {
        if (onRest.boolValue) {
            self.titleLabel.text = model.restTitle;
        }
    }];
    [RACObserve(model, circleColor) subscribeNext:^(UIColor *color) {
        self.titleLabel.backgroundColor = color;
    }];
    [RACObserve(model, currentLap) subscribeNext:^(NSNumber *currentLap) {
        if (!self.timerModel.timerOnPrepare) {
            self.roundNumberLabel.text = [NSString stringWithFormat:@"%@/%@", currentLap, self.timerModel.countOfLaps];
            self.roundLabel.text = @"Round";
        }
    }];
}

#pragma mark - Actions

- (IBAction)stopWorkoutAction:(id)sender {
    [self.timerModel stopTimer];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Stop Workout" message:@"Workout not finished. Go to main view?" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
        [self.timerModel resumeTimer];
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)pauseWorkoutAction:(id)sender {
    [self.tabataTimerView handlePauseAction];
}

- (IBAction)muteVolumeAction:(id)sender {
    [self.timerModel setMute:!self.timerModel.mute];
}

- (void)stopTimer {
    [self.tabataTimerView stopTimer];
}

- (void)resumeTimer {
    [self.tabataTimerView resumeTimer];
}

@end
