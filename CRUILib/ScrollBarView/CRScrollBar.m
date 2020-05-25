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
    NSMutableArray *_leftButtonView;
    NSMutableArray *_rightButtonView;
    NSMutableArray *_middleButtonView;
    BOOL _scrollItemFixed;       // scroll item 是否采用固定宽度
    CGFloat _scrollItemTotalWidth;   // scroll item 的整体宽度（包含间隔）
    NSUInteger _selectedIndex;
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
        _rightButtonView = [[NSMutableArray alloc] init];
        _leftButtonView = [[NSMutableArray alloc] initWithCapacity:0];
        _middleButtonView = [[NSMutableArray alloc] initWithCapacity:0];
        _selectedIndex = kDefaultSelectIdx;
        
        [self createScrollView];
    }
    return self;
}

- (void)createScrollView{
    _rScrollView = [[UIScrollView alloc] init];
    _rScrollView.showsVerticalScrollIndicator = NO;
    _rScrollView.showsHorizontalScrollIndicator = NO;
    _rScrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    [self addSubview:_rScrollView];
    _rScrollView.backgroundColor = UIColor.whiteColor;

    _shadowLayer = [CALayer layer];
    _shadowLayer.backgroundColor = UIColor.lightGrayColor.CGColor;
    [self.layer addSublayer:_shadowLayer];
}

#pragma mark - view
- (void)layoutSubviews{
    [super layoutSubviews];
    NSLog(@"%@",_shadowLayer);
    // shadow
    _shadowLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-1, CGRectGetWidth(self.bounds), 1);

    
    CGFloat itemHei = self.bounds.size.height - _config.padding.top - _config.padding.bottom - _config.itemMargin.top - _config.itemMargin.bottom;
    CGFloat itemTop = _config.padding.top + _config.itemMargin.top;
    /// left
    CGFloat leftX = _config.padding.left;
    for (UIButton *button in _leftButtonView) {
        CGRect btnFrame = CGRectMake(0, itemTop, CGRectGetWidth(button.bounds), itemHei);
        btnFrame.origin.x = leftX + _config.itemMargin.left;
        button.frame = btnFrame;
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        
        leftX += (btnFrame.size.width + _config.itemMargin.left + _config.itemMargin.right);
    }
    /// right
    CGFloat rightX = CGRectGetWidth(self.bounds) - _config.padding.right;
    for (UIButton *button in _rightButtonView) {
        CGRect btnFrame = CGRectMake(0, itemTop, CGRectGetWidth(button.bounds), itemHei);
        btnFrame.origin.x = (rightX - _config.itemMargin.left - _config.itemMargin.right - CGRectGetWidth(btnFrame));
        button.frame = btnFrame;
        button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        
        rightX -= (btnFrame.size.width + _config.itemMargin.left + _config.itemMargin.right);
    }
    
    CGRect scrollVFrame = CGRectMake(leftX, itemTop, MAX(0, rightX - leftX) , itemHei);
    _rScrollView.frame = scrollVFrame;
    [self layoutScrollViewSubviews];
}

- (void)layoutScrollViewSubviews{
    if (0 == _middleButtonView.count) {
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
        
        CGFloat itemWid = (CGRectGetWidth(_rScrollView.bounds) - _config.scrollPadding.left - _config.scrollPadding.right -  _config.scrollItemInterval * (_middleButtonView.count - 1)) / _middleButtonView.count;
        for (UIButton *button in _middleButtonView) {
            CGRect btnFrame = CGRectMake(leftX, itemTop, itemWid, itemHei);
            button.frame = btnFrame;
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            
            leftX += btnFrame.size.width + _config.scrollItemInterval;
        }
    }else{
        _rScrollView.contentSize = CGSizeMake(_scrollItemTotalWidth, CGRectGetHeight(_rScrollView.bounds));
        for (UIButton *button in _middleButtonView) {
            CGRect btnFrame = CGRectMake(leftX, itemTop, button.crScrollRealWidth, itemHei);
            button.frame = btnFrame;
            button.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
            
            leftX += (btnFrame.size.width + _config.scrollItemInterval);
        }
    }
}

#pragma mark - Refresh View
- (void)refreshLeftItem{
    
}
- (void)refreshRightItem{
    UITableView *tt;
}
- (void)refreshMiddleItem{
    
}
- (void)refreshAllItem{
    [self refreshLeftItem];
    [self refreshRightItem];
    [self refreshMiddleItem];
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
        btnSize = _config.imageSize;
    }
    btnSize.width += (_config.itemPadding.left + _config.itemPadding.right);    // 扩大范围
    button.bounds = CGRectMake(0, 0, btnSize.width, btnSize.height);
}

- (void)configScrollItemButton:(UIButton *)button item:(UIBarButtonItem *)item{
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
    btnSize.width += (_config.scrollItemOffset * 2);        // 扩大范围
    button.bounds = CGRectMake(0, 0, btnSize.width, btnSize.height);
    button.crScrollRealWidth = btnSize.width;
    button.backgroundColor = UIColor.whiteColor;
#if BKCOLOR
    button.backgroundColor = UIColor.redColor ;
#endif
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
- (void)setLeftItem:(NSArray<UIBarButtonItem *> *)leftItem{
    _leftItem = [leftItem copy];
    [self setSideItems:_leftItem viewContain:_leftButtonView];
}

- (void)setRightItem:(NSArray<UIBarButtonItem *> *)rightItem{
    _rightItem = [rightItem copy];
    [self setSideItems:_rightItem viewContain:_rightButtonView];
}

- (void)setSideItems:(NSArray<UIBarButtonItem *> *)items viewContain:(NSMutableArray *)views{
    [views removeAllObjects];
    for (UIBarButtonItem *item in items) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configButton:button item:item];
        [button addTarget:item.target action:item.action forControlEvents:UIControlEventTouchUpInside];
        [views addObject:button];
        [self addSubview:button];
    }
}

- (void)setMiddleItem:(NSArray<CRScrollBarItem *> *)middleItem{
    _middleItem = [middleItem copy];
    [_middleButtonView removeAllObjects];
    
    _scrollItemFixed = YES;
    if (_middleItem.count < 1) {
        return;
    }
    
    _scrollItemTotalWidth = 0;
    NSInteger tagOffset = kTagOffset;
    for (UIBarButtonItem *item in _middleItem) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self configScrollItemButton:button item:item];
        button.tag = tagOffset++;
        [button addTarget:self action:@selector(clickScrollButton:) forControlEvents:UIControlEventTouchUpInside];
        [_middleButtonView addObject:button];
        [_rScrollView addSubview:button];
        _scrollItemTotalWidth += button.crScrollRealWidth;
    }
    _scrollItemTotalWidth += ((middleItem.count - 1) * _config.scrollItemInterval);  // 间隙

    [self layoutScrollViewSubviews];
}

- (NSUInteger)indexForSelected{
    return _selectedIndex;
}

- (void)setTintColor:(UIColor *)tintColor{
    if (self.tintColor == tintColor) {
        return;
    }
    _tintColor = tintColor;
    for (UIButton *btn in _middleButtonView) {
        [btn setTintColor:tintColor];
    }
}

- (void)setSelectedColor:(UIColor *)selectedColor{
    if (self.selectedColor == selectedColor) {
        return;
    }
    _selectedColor = selectedColor;
    for (UIButton *btn in _middleButtonView) {
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
