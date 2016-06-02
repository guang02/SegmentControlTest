//
//  MGSegmentControl.m
//  SegmentConstrol
//
//  Created by qie on 16/6/2.
//  Copyright © 2016年 qie. All rights reserved.
//

#import "MGSegmentControl.h"

@interface MGScrollView : UIScrollView

@end


@interface MGSegmentControl()

@property (nonatomic, readwrite) CGFloat segmentWidth;
@property (nonatomic, strong) MGScrollView *scrollView;
@property (nonatomic, strong) CALayer *selectionIndicatorLayer;
@property (nonatomic, strong) NSArray *sectionTitles;

@end

@implementation MGScrollView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        [self.nextResponder touchesBegan:touches withEvent:event];
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!self.dragging) {
        [self.nextResponder touchesMoved:touches withEvent:event];
    } else{
        [super touchesMoved:touches withEvent:event];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!self.dragging) {
        [self.nextResponder touchesEnded:touches withEvent:event];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

@end

@implementation MGSegmentControl

- (id)initWithSectionTitles:(NSArray *)sectionTitles {
    self = [self initWithFrame:CGRectZero];
    
    if (self) {
        [self commonInit];
        self.sectionTitles = sectionTitles;
    }
    return self;
}

-(void)commonInit{
    self.scrollView = [[MGScrollView alloc] init];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.scrollView];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    
    NSDictionary *defaults = @{
                               NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                               NSForegroundColorAttributeName : [UIColor redColor],
                               };
    [self setSelectedTitleTextAttributes:defaults];
    self.selectionIndicatorLayer = [CALayer layer];
    
    self.selectionIndicatorHeight = 2.f;
    self.opaque = NO;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    [self updateSegmentsRects];
}

- (NSUInteger)sectionCount {
    return self.sectionTitles.count;
}

- (CGFloat)totalSegmentedControlWidth {
    return self.sectionTitles.count * self.segmentWidth;
}

-(void)updateSegmentsRects{
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    
    if ([self sectionCount] > 0) {
        self.segmentWidth = self.frame.size.width / [self sectionCount];
    }
    self.scrollView.contentSize = CGSizeMake([self totalSegmentedControlWidth], self.frame.size.height);
}

-(void)drawRect:(CGRect)rect{
    [self.backgroundColor setFill];
    UIRectFill([self bounds]);
    
    self.selectionIndicatorLayer.backgroundColor = [UIColor redColor].CGColor;
    
    // Remove all sublayers to avoid drawing images over existing ones
    self.scrollView.layer.sublayers = nil;
    
    [self.sectionTitles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat stringWidth = 0;
        CGFloat stringHeight = 0;
        CGSize size = [self measureTitleAtIndex:idx];
        stringWidth = size.width;
        stringHeight = size.height;
        
        CGFloat y = (CGRectGetHeight(self.frame)-self.selectionIndicatorHeight- stringHeight)/2;
        
        CGRect rect = CGRectMake(self.segmentWidth*idx + (self.segmentWidth - stringWidth) / 2, y, stringWidth, stringHeight);
        
        CATextLayer *titleLayer = [CATextLayer layer];
        titleLayer.frame = rect;
        titleLayer.alignmentMode = kCAAlignmentCenter;
        titleLayer.truncationMode = kCATruncationEnd;
        titleLayer.string = obj;
        titleLayer.string = [self attributedTitleAtIndex:idx];
        titleLayer.contentsScale = [[UIScreen mainScreen] scale];
        
        [self.scrollView.layer addSublayer:titleLayer];
    }];
    
    if (!self.selectionIndicatorLayer.superlayer) {
        [self setArrowFrame];
        [self.scrollView.layer addSublayer:self.selectionIndicatorLayer];
    }
}

-(void)setArrowFrame{
    self.selectionIndicatorLayer.frame = [self frameForSelectionIndicator];
}

-(CGRect)frameForSelectionIndicator{
    return CGRectMake(self.selectedSegmentIndex*self.segmentWidth, CGRectGetHeight(self.frame)-self.selectionIndicatorHeight, self.segmentWidth, self.selectionIndicatorHeight);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInView:self];
    
    if (CGRectContainsPoint(self.bounds, touchLocation)) {
        NSInteger segment = (touchLocation.x + self.scrollView.contentOffset.x) / self.segmentWidth;
        [self setSelectedSegmentIndex:segment animated:YES];
    }
}

-(void)setSelectedSegmentIndex:(NSInteger)index animated:(BOOL)animated{
    _selectedSegmentIndex = index;
    [self setNeedsDisplay];
    [self setArrowFrame];
}

- (CGSize)measureTitleAtIndex:(NSUInteger)index {
    id title = self.sectionTitles[index];
    CGSize size = CGSizeZero;
    
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
    
    if ([title isKindOfClass:[NSString class]]) {
        NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes]: [self resultingTitleTextAttributes];
        size = [(NSString *)title sizeWithAttributes:titleAttrs];
    }else{
        size = CGSizeZero;
    }
    
    return CGRectIntegral((CGRect){CGPointZero, size}).size;
}

- (NSDictionary *)resultingTitleTextAttributes {
    NSDictionary *defaults = @{
                               NSFontAttributeName : [UIFont systemFontOfSize:17.0f],
                               NSForegroundColorAttributeName : [UIColor blackColor],
                               };
    
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:defaults];
    
    if (self.titleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.titleTextAttributes];
    }
    
    return [resultingAttrs copy];
}

- (NSDictionary *)resultingSelectedTitleTextAttributes {
    NSMutableDictionary *resultingAttrs = [NSMutableDictionary dictionaryWithDictionary:[self resultingTitleTextAttributes]];
    
    if (self.selectedTitleTextAttributes) {
        [resultingAttrs addEntriesFromDictionary:self.selectedTitleTextAttributes];
    }
    
    return [resultingAttrs copy];
}

- (NSAttributedString *)attributedTitleAtIndex:(NSUInteger)index {
    id title = self.sectionTitles[index];
    BOOL selected = (index == self.selectedSegmentIndex) ? YES : NO;
    NSDictionary *titleAttrs = selected ? [self resultingSelectedTitleTextAttributes] : [self resultingTitleTextAttributes];
    // the color should be cast to CGColor in order to avoid invalid context on iOS7
    UIColor *titleColor = titleAttrs[NSForegroundColorAttributeName];
    if (titleColor) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:titleAttrs];
        dict[NSForegroundColorAttributeName] = (id)titleColor.CGColor;
        titleAttrs = [NSDictionary dictionaryWithDictionary:dict];
    }
    return [[NSAttributedString alloc] initWithString:(NSString *)title attributes:titleAttrs];
}

@end
