//
//  CRScrollBar.m
//  Scroll
//
//  Created by Crazs on 2020/5/9.
//  Copyright © 2020 Crazs. All rights reserved.
//

#import "CRScrollBar.h"
#import <objc/runtime.h>

#define kTagOffset          1000
#define kDefaultSelectIdx   0xFFFF

/**
 @brief 记录button 宽度
 */
@interface UIButton (CRScrollItemButton)
@property (nonatomic, assign) CGFloat crScrollRealWidth;    // 记录真实宽度
@end


@interface CRScrollBar (){
    UIScrollView *_rScrollView;
    UIView *_leftContainView;
    UIView *_rightContainView;
//    NSMutableArray *_leftButtonViews;
//    NSMutableArray *_rightButtonViews;
    NSMutableArray *_middleButtonViews;
    BOOL _scrollItemFixed;              // scroll item 是否采用固定宽度
    CGFloat _scrollItemTotalWidth;      // scroll item 的整体宽度（包含间隔）
    NSUInteger _selectedIndex;
    
    BOOL _refreshLeft;                  // 是否刷新左侧
    BOOL _refreshRight;                 // 是否刷新右侧
    BOOL _refreshMiddle;                // 是否刷新中间
    CGFloat _recordItemHeight;          // 记录Item高度
}

@end

@implementation CRScrollBar

- (instancetype)init{
    return [self initWithConfig:[CRScrollBarConfig defaultConfig]];
}
- (instancetype)initWithConfig:(CRScrollBarConfig *)config{
    self = [super initWithFrame:CGRectMake(0, 0, 375, 44)];
    if (self) {
        _config = config;
        _middleButtonViews = [[NSMutableArray alloc] initWithCapacity:0];
        _selectedIndex = kDefaultSelectIdx;
        
        [self createScrollView];
    }
    return self;
}

- (void)createScrollView{
    _rScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(_config.padding.left, _config.padding.top, self.bounds.size.width - _config.padding.left - _config.padding.right, self.bounds.size.height - _config.padding.top - _config.padding.bottom)];
    _rScrollView.showsVerticalScrollIndicator = NO;
    _rScrollView.showsHorizontalScrollIndicator = NO;
    _rScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self addSubview:_rScrollView];
    _rScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

#pragma mark - view
- (void)layoutSubviews{
    [super layoutSubviews];

    CGFloat sideItemTop = _config.itemMargin.top;
    CGFloat sideItemHei = self.bounds.size.height - _config.padding.top - _config.padding.bottom - _config.itemMargin.top - _config.itemMargin.bottom;
    BOOL heightChange = sideItemHei != _recordItemHeight;
    _recordItemHeight = sideItemHei;
    
    /// left
    if (heightChange || _refreshLeft) {
        if (!_leftContainView ) {
            _refreshLeft = NO;
            return;
        }
        CGFloat leftX = 0;
        for (UIButton *button in _leftContainView.subviews) {
            CGRect btnFrame = CGRectMake(0, sideItemTop, CGRectGetWidth(button.bounds), sideItemHei);
            btnFrame.origin.x = leftX + _config.itemMargin.left;
            button.frame = btnFrame;
            
            leftX = (CGRectGetMaxX(btnFrame) + _config.itemMargin.right);
        }
        CGRect leftFrame = _leftContainView.frame;
        leftFrame.size.width = leftX;
        _leftContainView.frame = leftFrame;
        
        _refreshLeft = NO;
    }
    
    /// right
    if (heightChange || _refreshRight) {
        if (!_rightContainView) {
            _refreshRight = NO;
            return;
        }
        CGFloat rightX = CGRectGetMaxX(_rightContainView.bounds);
        for (UIButton *button in _rightContainView.subviews) {
            CGRect btnFrame = CGRectMake(0, sideItemTop, CGRectGetWidth(button.bounds), sideItemHei);
            btnFrame.origin.x = (rightX - _config.itemMargin.right - CGRectGetWidth(btnFrame));
            button.frame = btnFrame;
        
            rightX = (CGRectGetMinX(btnFrame) - _config.itemMargin.left);
        }
        CGRect rightFrame = _rightContainView.frame;
        rightFrame.size.width = CGRectGetWidth(rightFrame) - rightX;
        rightFrame.origin.x = CGRectGetWidth(self.bounds) - rightFrame.size.width - _config.padding.right;
        _rightContainView.frame = rightFrame;
        
        _refreshRight = NO;
    }
    CGRect scrollVFrame = _rScrollView.frame;
    BOOL scrollWidthRecord = scrollVFrame.size.width;
    scrollVFrame.origin.x = _leftContainView ? (CGRectGetMaxX(_leftContainView.frame)) : (_config.padding.left);
    CGFloat scrollRight = _rightContainView ? (CGRectGetMinX(_rightContainView.frame)) : (CGRectGetWidth(self.bounds) - _config.padding.right);
    scrollVFrame.size.width = MAX(0, scrollRight - scrollVFrame.origin.x);
    _rScrollView.frame = scrollVFrame;
    
    if (heightChange || _refreshMiddle || scrollWidthRecord != scrollVFrame.size.width) {
        // 改变刷新
        [self layoutScrollViewSubviews];
    }
}

- (void)layoutScrollViewSubviews{
    if (0 == _middleButtonViews.count) {
        _rScrollView.contentSize = _rScrollView.bounds.size;
        _rScrollView.contentOffset = CGPointZero;
        return;
    }
    
    CGFloat itemHei = _rScrollView.bounds.size.height - _config.scrollPadding.top - _config.scrollPadding.bottom;
    CGFloat itemTop = _config.scrollPadding.top;
    CGFloat leftX = _config.scrollPadding.left;
    
    _scrollItemFixed = _scrollItemTotalWidth <= (CGRectGetWidth(_rScrollView.bounds) - _config.scrollPadding.left - _config.scrollPadding.right);
    if (_scrollItemFixed) {
        _rScrollView.contentSize = _rScrollView.bounds.size;
        _rScrollView.contentOffset = CGPointZero;
        
        CGFloat itemWid = (CGRectGetWidth(_rScrollView.bounds) - _config.scrollPadding.left - _config.scrollPadding.right -  _config.scrollItemInterval * (_middleButtonViews.count - 1)) / _middleButtonViews.count;
        for (UIButton *button in _middleButtonViews) {
            CGRect btnFrame = CGRectMake(leftX, itemTop, itemWid, itemHei);
            button.frame = btnFrame;
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            
            leftX += btnFrame.size.width + _config.scrollItemInterval;
        }
    }else{
        _rScrollView.contentSize = CGSizeMake(_scrollItemTotalWidth, CGRectGetHeight(_rScrollView.bounds));
        for (UIButton *button in _middleButtonViews) {
            CGRect btnFrame = CGRectMake(leftX, itemTop, button.crScrollRealWidth, itemHei);
            button.frame = btnFrame;
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
            
            leftX += (btnFrame.size.width + _config.scrollItemInterval);
        }
    }
}

#pragma mark - Refresh View
- (void)refreshLeftItem{
    _refreshLeft = YES;
    [self setNeedsLayout];
}
- (void)refreshRightItem{
    _refreshRight = YES;
    [self setNeedsLayout];
}
- (void)refreshMiddleItem{
    _refreshMiddle = YES;
    [self setNeedsLayout];
}
- (void)refreshAllItem{
    _refreshLeft = YES;
    _refreshRight = YES;
    _recordItemHeight = YES;
    [self setNeedsLayout];
}

#pragma mark - Refresh Button
- (void)configButton:(UIButton *)button item:(UIBarButtonItem *)item{
    if (nil == button || nil == item) {
        return;
    }
    
    CGSize btnSize = CGSizeZero;
    if (item.title && item.title.length > 0) {
        [button setTitle:item.title forState:UIControlStateNormal];
        [button.titleLabel setFont:_config.titleFont];
        [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        
        for (NSNumber *state in _config.allStates) {
            NSDictionary *attributeDic = [_config titleTextAttributesForState:state.unsignedIntegerValue];
            NSAttributedString *attributeString = [[NSAttributedString alloc] initWithString:item.title attributes:attributeDic];
            [button setAttributedTitle:attributeString forState:state.unsignedIntegerValue];
        }
        
        if ([_config titleTextAttributesForState:UIControlStateNormal]) {
            CGRect textRect = [item.title boundingRectWithSize:CGSizeMake(375, 375) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:[_config titleTextAttributesForState:UIControlStateNormal] context:nil];
            btnSize = textRect.size;
        }else{
            CGRect textRect = [item.title boundingRectWithSize:CGSizeMake(375, 375) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_config.titleFont} context:nil];
            btnSize = textRect.size;
        }
    }else if (item.image){
        [button setImage:item.image forState:UIControlStateNormal];
        button.imageView.contentMode = UIViewContentModeScaleAspectFit;
        btnSize = _config.imageSize;
    }
    button.bounds = CGRectMake(0, 0, btnSize.width, btnSize.height);
}

- (void)extendSideButton:(UIButton *)button{
    CGSize btnSize = button.bounds.size;
    btnSize.width += (_config.itemPadding.left + _config.itemPadding.right);
    button.bounds = CGRectMake(0, 0, btnSize.width, btnSize.height);
}

- (void)extendScrollButton:(UIButton *)button{
    CGSize btnSize = button.bounds.size;
    btnSize.width += (_config.scrollItemOffset * 2);
    button.bounds = CGRectMake(0, 0, btnSize.width, btnSize.height);
}

#pragma mark - Function
- (void)selecteIndex:(NSUInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(crScrollBar:canSelectIndex:)] && ![self.delegate crScrollBar:self canSelectIndex:index]) {
        return;
    }
    UIButton *selectBtn = [_rScrollView viewWithTag:kTagOffset + index];
    if (selectBtn) {
        if (index != _selectedIndex && kDefaultSelectIdx != _selectedIndex) {
            [self deselectIndex:_selectedIndex];
        }
        
        // 2.选中当前
        selectBtn.selected = YES;
        _selectedIndex = index;
        if ([self.delegate respondsToSelector:@selector(crScrollBar:didSelectedIndex:)]) {
            [self.delegate crScrollBar:self didSelectedIndex:_selectedIndex];
        }
    }
}

- (void)deselectIndex:(NSUInteger)index{
    UIButton *selectedBtn = [_rScrollView viewWithTag:kTagOffset + index];
    if (selectedBtn && selectedBtn.selected) {
        selectedBtn.selected = NO;
        if ([self.delegate respondsToSelector:@selector(crScrollBar:didDeselectedIndex:)]) {
            [self.delegate crScrollBar:self didDeselectedIndex:_selectedIndex];
        }
        _selectedIndex = kDefaultSelectIdx;
    }
}


- (void)clickScrollButton:(UIButton *)button{
    
    [self selecteIndex:button.tag - kTagOffset];
}

#pragma mark - Setter & Getter
- (void)setLeftItems:(NSArray<UIBarButtonItem *> *)leftItem{
    _leftItems = [leftItem copy];
    
    if (_leftItems.count) {
        if (!_leftContainView) {
            CGRect leftViewFrame = CGRectMake(_config.padding.left, _config.padding.top, CGFLOAT_MIN, CGRectGetHeight(self.bounds) - _config.padding.top - _config.padding.bottom);
            _leftContainView = [[UIView alloc] initWithFrame:leftViewFrame];
            _leftContainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        }
        [self addSubview:_leftContainView];
    }else if (_leftContainView){
        [_leftContainView removeFromSuperview];
        _leftContainView = nil;
    }
    
    for (UIBarButtonItem *item in _leftItems) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configButton:button item:item];
        [self extendSideButton:button];
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
        
        [_leftContainView addSubview:button];
    }
    _refreshLeft = YES;
    [self setNeedsLayout];
}

- (void)setRightItems:(NSArray<UIBarButtonItem *> *)rightItem{
    _rightItems = [rightItem copy];
    
    if (rightItem.count) {
        if (!_rightContainView) {
            CGRect rightViewFrame = CGRectMake(_config.itemMargin.right - CGFLOAT_MIN, _config.padding.top, CGFLOAT_MIN, CGRectGetHeight(self.bounds)-_config.padding.top - _config.padding.bottom);
            _rightContainView = [[UIView alloc] initWithFrame:rightViewFrame];
            _rightContainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        }
         [self addSubview:_rightContainView];
     }else if (_leftContainView){
         [_rightContainView removeFromSuperview];
         _rightContainView = nil;
     }
    
    for (UIBarButtonItem *item in _rightItems) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configButton:button item:item];
        [self extendSideButton:button];
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
        
        [_rightContainView addSubview:button];
    }
    _refreshRight = YES;
    [self setNeedsLayout];
}

- (void)setMiddleItems:(NSArray<CRScrollBarItem *> *)middleItem{
    _refreshMiddle = YES;
    _middleItems = [middleItem copy];
    [_middleButtonViews removeAllObjects];
    
    _scrollItemFixed = YES;
    if (_middleItems.count < 1) {
        return;
    }
    
    _scrollItemTotalWidth = 0;
    NSInteger tagOffset = kTagOffset;
    for (UIBarButtonItem *item in _middleItems) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configButton:button item:item];
        button.crScrollRealWidth = CGRectGetWidth(button.bounds);
        [self extendScrollButton:button];
        [button addTarget:self action:@selector(clickScrollButton:) forControlEvents:UIControlEventTouchUpInside];
        
        button.tag = tagOffset++;
        [_middleButtonViews addObject:button];
        [_rScrollView addSubview:button];
        _scrollItemTotalWidth += button.crScrollRealWidth;
    }
    _scrollItemTotalWidth += ((middleItem.count - 1) * _config.scrollItemInterval);  // 间隙

    [self layoutScrollViewSubviews];
}

- (NSUInteger)indexForSelected{
    return _selectedIndex;
}

#pragma mark - view config
- (void)setTintColor:(UIColor *)tintColor{
    if (self.tintColor == tintColor) {
        return;
    }
    _tintColor = tintColor;
    for (UIButton *btn in _middleButtonViews) {
        [btn setBackgroundColor:tintColor];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    if (self.selectedColor == selectedColor) {
        return;
    }
    _selectedColor = selectedColor;
    for (UIButton *btn in _middleButtonViews) {
        [btn setTitleColor:selectedColor forState:UIControlStateSelected];
    }
}

@end


@implementation UIButton (CRScrollItemButton)

- (void)setCrScrollRealWidth:(CGFloat)crScrollRealWidth{
    objc_setAssociatedObject(self, @selector(crScrollRealWidth), @(crScrollRealWidth), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)crScrollRealWidth{
    return ((NSNumber *)objc_getAssociatedObject(self, @selector(crScrollRealWidth))).doubleValue;
}
@end
