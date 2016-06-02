//
//  MGSegmentControl.h
//  SegmentConstrol
//
//  Created by qie on 16/6/2.
//  Copyright © 2016年 qie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MGSegmentControl : UIControl

@property (nonatomic, assign) NSInteger selectedSegmentIndex;

@property (nonatomic, readwrite) CGFloat selectionIndicatorHeight;

@property (nonatomic, strong) NSDictionary *titleTextAttributes UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSDictionary *selectedTitleTextAttributes UI_APPEARANCE_SELECTOR;

- (id)initWithSectionTitles:(NSArray *)sectionTitles;

@end
