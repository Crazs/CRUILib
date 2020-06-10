//
//  CRScrollBar.m
//  Scroll
//
//  Created by Crazs on 2020/5/9.
//  Copyright © 2020 Crazs. All rights reserved.
//

#import "CRScrollBar.h"
#import <objc/runtime.h>


const static NSInteger kTagOffset = 1000;

const static NSString *kLeftItemBindKey     = @"LeftBarItemBindKey";
const static NSString *kRightItemBindKey    = @"RightBarItemBindKey";
const static NSString *kMiddleItemBindKey   = @"MiddleBarItemBindKey";

/**
 @brief 记录button 宽度
 */
@interface UIButton (CRScrollItemButton)
@property (nonatomic, assign) CGFloat crScrollRealWidth;    // 记录真实宽度
@end


@interface CRScrollBar (){
    UIView *_leftContainView;
    UIView *_rightContainView;

    NSMutableArray *_middleButtonViews;
    BOOL _scrollItemFixed;              // scroll item 是否采用固定宽度
    CGFloat _scrollItemTotalWidth;      // scroll item 的整体宽度（包含间隔）
    
    BOOL _refreshLeft;                  // 是否刷新左侧
    BOOL _refreshRight;                 // 是否刷新右侧
    BOOL _refreshMiddle;                // 是否刷新中间
    CGFloat _recordItemHeight;          // 记录Item高度
    
    NSMutableDictionary *_barItemBindDict;   // item绑定的信息
}
@property (nonatomic, strong) UIScrollView *rScrollView;

@end

@implementation CRScrollBar
+ (NSInteger)tagOffset{
    return kTagOffset;
}

- (instancetype)init{
    return [self initWithConfig:[CRScrollBarConfig defaultConfig]];
}
- (instancetype)initWithConfig:(CRScrollBarConfig *)config{
    self = [super initWithFrame:CGRectMake(0, 0, 375, 44)];
    if (self) {
        _config = config;
        _middleButtonViews = [[NSMutableArray alloc] initWithCapacity:0];
        _barItemBindDict = [[NSMutableDictionary alloc] initWithCapacity:0];
        
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

#pragma mark - Config Button
- (void)configButton:(UIButton *)button item:(UIBarItem *)item{
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

#

- (void)clickScrollButton:(UIButton *)button{
    if (self.delegate && [self.delegate respondsToSelector:@selector(crScrollBar:canSelectIndex:)] && ![self.delegate crScrollBar:self canSelectIndex:button.tag - kTagOffset]) {
        return;
    }
}

#pragma mark - Setter & Getter
- (void)setLeftItems:(NSArray<UIBarButtonItem *> *)leftItem{
    _leftItems = [leftItem copy];
    
    NSMutableDictionary *leftItenBindDict;
    if (_leftItems.count) {
        CGRect leftViewFrame = CGRectMake(_config.padding.left, _config.padding.top, CGFLOAT_MIN, CGRectGetHeight(self.bounds) - _config.padding.top - _config.padding.bottom);
        _leftContainView = [[UIView alloc] initWithFrame:leftViewFrame];
        _leftContainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [self addSubview:_leftContainView];

        leftItenBindDict = [[NSMutableDictionary alloc] initWithCapacity:leftItem.count];
        [_barItemBindDict setObject:leftItenBindDict forKey:kLeftItemBindKey];
    }else if (_leftContainView){
        [_leftContainView removeFromSuperview];
        _leftContainView = nil;
        
        [_barItemBindDict removeObjectForKey:kLeftItemBindKey];
    }
    
     
    for (UIBarButtonItem *item in _leftItems) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configButton:button item:item];
        [self extendSideButton:button];
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        [button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
        [_leftContainView addSubview:button];
        
        [leftItenBindDict setObject:button forKey:@(item.hash).stringValue];
        [self addItemObserver:item];
    }
    _refreshLeft = YES;
    [self setNeedsLayout];
}

- (void)setRightItems:(NSArray<UIBarButtonItem *> *)rightItem{
    _rightItems = [rightItem copy];
    
    NSMutableDictionary *rightItenBindDict;
    if (rightItem.count) {
        CGRect rightViewFrame = CGRectMake(_config.itemMargin.right - CGFLOAT_MIN, _config.padding.top, CGFLOAT_MIN, CGRectGetHeight(self.bounds)-_config.padding.top - _config.padding.bottom);
        _rightContainView = [[UIView alloc] initWithFrame:rightViewFrame];
        _rightContainView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [self addSubview:_rightContainView];

        rightItenBindDict = [[NSMutableDictionary alloc] init];
        [_barItemBindDict setObject:rightItenBindDict forKey:kRightItemBindKey];
     }else if (_leftContainView){
         [_rightContainView removeFromSuperview];
         _rightContainView = nil;
         
         [_barItemBindDict removeObjectForKey:kRightItemBindKey];
     }
    
    for (UIBarButtonItem *item in _rightItems) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configButton:button item:item];
        [self extendSideButton:button];
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        [button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
        [_rightContainView addSubview:button];
        
        [rightItenBindDict setObject:button forKey:@(item.hash).stringValue];
        [self addItemObserver:item];
    }
    _refreshRight = YES;
    [self setNeedsLayout];
}

- (void)setMiddleItems:(NSArray<CRScrollBarItem *> *)middleItem{
    _refreshMiddle = YES;
    _middleItems = [middleItem copy];
    [_middleButtonViews removeAllObjects];
    [_barItemBindDict removeObjectForKey:kMiddleItemBindKey];
    
    _scrollItemFixed = YES;
    if (_middleItems.count < 1) {
        return;
    }
    
    _scrollItemTotalWidth = 0;
    NSInteger tagOffset = kTagOffset;

    NSMutableDictionary *middleItenBindDict = [[NSMutableDictionary alloc] init];
    [_barItemBindDict setObject:middleItenBindDict forKey:kMiddleItemBindKey];

    for (CRScrollBarItem *item in _middleItems) {
        // 创建并设置button的属性
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configButton:button item:item];
        button.crScrollRealWidth = CGRectGetWidth(button.bounds);
        [self extendScrollButton:button];
        [button addTarget:self action:@selector(clickScrollButton:) forControlEvents:UIControlEventTouchUpInside];
        
        // 将button添加到view上
        button.tag = tagOffset++;
        [_middleButtonViews addObject:button];
        [_rScrollView addSubview:button];
        _scrollItemTotalWidth += button.crScrollRealWidth;
        
        
        // 监听item的属性变化
        [middleItenBindDict setObject:button forKey:@(item.hash).stringValue];
        [self addItemObserver:item];
    }
    _scrollItemTotalWidth += ((middleItem.count - 1) * _config.scrollItemInterval);  // 间隙

    [self layoutScrollViewSubviews];
}
#pragma mark - KVO
#define D_keyPath_title     @"title"
#define D_keyPath_image     @"image"

- (void)addItemObserver:(UIBarItem *)item{
    [item addObserver:self forKeyPath:D_keyPath_title options:NSKeyValueObservingOptionNew context:nil];
    [item addObserver:self forKeyPath:D_keyPath_image options:NSKeyValueObservingOptionNew context:nil];
}



- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    
    if (![object isKindOfClass:[UIBarItem class]]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }else if (![keyPath isEqualToString:D_keyPath_title] &&
              ![keyPath isEqualToString:D_keyPath_image]) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }else{
        if (!_barItemBindDict) {
            return;
        }
        UIButton *refreshButton;
        NSString *refreshSymbString;
        for (NSString *keyString in [_barItemBindDict allKeys]) {
            NSMutableDictionary *containDic = _barItemBindDict[keyString];
            if ([containDic objectForKey:@(((UIBarItem *)object).hash).stringValue]) {
                refreshSymbString = keyString;
                refreshButton = [containDic objectForKey:@(((UIBarItem *)object).hash).stringValue];
                break;;
            }
        }

        if ([refreshSymbString isEqualToString:(NSString *)kLeftItemBindKey]) {
            _refreshLeft = YES;
        }else if ([refreshSymbString isEqualToString:(NSString *)kRightItemBindKey]) {
            _refreshRight = YES;
        }else if ([refreshSymbString isEqualToString:(NSString *)kMiddleItemBindKey]) {
            _refreshMiddle = YES;
        }
        if (refreshButton) {
            [self configButton:refreshButton item:object];
        }
        [self setNeedsLayout];
    }
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
