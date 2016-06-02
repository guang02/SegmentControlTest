//
//  ViewController.m
//  SegmentConstrol
//
//  Created by qie on 16/6/2.
//  Copyright © 2016年 qie. All rights reserved.
//

#import "ViewController.h"

#import "MGSegmentControl.h"

@interface ViewController (){
    MGSegmentControl *segmentControl;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    segmentControl = [[MGSegmentControl alloc] initWithSectionTitles:@[@"History", @"News"]];
    [segmentControl setFrame:CGRectMake(0, 20, CGRectGetHeight(self.view.frame), 44)];
    
    self.navigationItem.titleView = segmentControl;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
