//
//  ABSetupTimerViewController.m
//  TabataTimer
//
//  Created by Alexey Bidnyk on 27.09.16.
//  Copyright © 2016 Alexey Bidnyk. All rights reserved.
//

#import "ABSetupTimerViewController.h"
#import "ABTimerViewController.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

#import "ABTimerModel.h"

#import "AppDelegate.h"

@interface ABSetupTimerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *countOfLapsLabel;
@property (weak, nonatomic) IBOutlet UILabel *prepareIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *workIntervalLabel;
@property (weak, nonatomic) IBOutlet UILabel *restIntervalLabel;

@property (weak, nonatomic) IBOutlet UITextField *countOfLapsTextField;
@property (weak, nonatomic) IBOutlet UITextField *prepareIntervalTextField;
@property (weak, nonatomic) IBOutlet UITextField *workIntervalTextField;
@property (weak, nonatomic) IBOutlet UITextField *restIntervalTextField;

@property (weak, nonatomic) IBOutlet UIButton *startWorkoutButton;

@property (strong, nonatomic) ABTimerModel *timerModel;

@end

@implementation ABSetupTimerViewController

#pragma mark - View life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupView];
    [self bindModel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.countOfLapsTextField becomeFirstResponder];
    
    self.countOfLapsTextField.text = @"";
    self.prepareIntervalTextField.text = @"";
    self.workIntervalTextField.text = @"";
    self.restIntervalTextField.text = @"";
}

- (void)setupView {
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                        action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:gestureRecognizer];
}

#pragma mark - Model binding

- (void)bindModel {
    self.timerModel = [ABTimerModel new];
    self.timerModel.prepareTitle = @"Prepare";
    self.timerModel.workTitle = @"Workout!";
    self.timerModel.restTitle = @"Rest";
    
    RAC(self.timerModel, countOfLaps) = [self.countOfLapsTextField.rac_textSignal map:^id(NSNumber *number) {
        return [self.timerModel valideLapsCount:number];
    }];
    
    RAC(self.timerModel, totalPrepareTime) = [self.prepareIntervalTextField.rac_textSignal map:^id(NSNumber *number) {
        NSTimeInterval timeInterval = [number floatValue];
        return @([self.timerModel valideTimeInterval:timeInterval]);
    }];
    
    RAC(self.timerModel, totalWorkTime) = [self.workIntervalTextField.rac_textSignal map:^id(NSNumber *number) {
        NSTimeInterval timeInterval = [number floatValue];
        return @([self.timerModel valideTimeInterval:timeInterval]);
    }];
    
    RAC(self.timerModel, totalRestTime) = [self.restIntervalTextField.rac_textSignal map:^id(NSNumber *number) {
        NSTimeInterval timeInterval = [number floatValue];
        return @([self.timerModel valideTimeInterval:timeInterval]);
    }];
    
    RAC(self.startWorkoutButton, enabled) = [RACSignal combineLatest:@[RACObserve(self.timerModel, countOfLaps),
                                                                       RACObserve(self.timerModel, totalPrepareTime),
                                                                       RACObserve(self.timerModel, totalWorkTime),
                                                                       RACObserve(self.timerModel, totalRestTime)]
                                                              reduce:^id(NSNumber *countOfLaps, NSTimeInterval prepareInterval, NSTimeInterval workInterval, NSTimeInterval restInterval){
                                                                  BOOL result = @([self.timerModel valideLapsCount:countOfLaps] &&
                                                                  [self.timerModel valideTimeInterval:prepareInterval] &&
                                                                  [self.timerModel valideTimeInterval:workInterval] &&
                                                                  [self.timerModel valideTimeInterval:restInterval]);
                                                                  return @(result);
    }];
}

#pragma mark - Actions

- (IBAction)startWorkoutAction:(UIButton *)sender {
    NSLog(@"Start Workout!");
    
    ABTimerViewController *timerViewController = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ABTimerViewController class])];
    timerViewController.timerModel = self.timerModel;
    
    [self pushViewControllerWithAnimation:timerViewController];
}

- (void)pushViewControllerWithAnimation:(UIViewController *)viewController {
    CATransition* transition = [CATransition animation];
    transition.duration = .5;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionFade; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    //transition.subtype = kCATransitionFromTop; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [[self navigationController] pushViewController:viewController animated:NO];
}

#pragma mark - Misc

- (void)hideKeyboard {
    [self.view endEditing:YES];
}

@end
