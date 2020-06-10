//
//  CRScrollSelectBar.m
//  CRUILib
//
//  Created by Crazs on 2020/6/5.
//

#import "CRScrollSelectBar.h"

#define D_kTagOffset    [CRScrollBar tagOffset]

const static NSUInteger gDefaultSelectIdx = 0xFFFF;

@interface CRScrollBar (CRScrollSelectedBar)
@property (nonatomic, strong) UIScrollView *rScrollView;
+ (NSInteger)tagOffset;
- (void)createScrollView;
@end

@interface CRScrollSelectBar () {
    NSUInteger _selectedIndex;
}
@end

@implementation CRScrollSelectBar

- (instancetype)initWithConfig:(CRScrollBarConfig *)config{
    self = [super initWithConfig:config];
    if (self) {
        _selectedIndex = gDefaultSelectIdx;
    }
    return self;
}


- (void)createScrollView{
    [super createScrollView];
    
    _shadowLayer = [CALayer layer];
    _shadowLayer.backgroundColor = UIColor.lightGrayColor.CGColor;
    [self.layer addSublayer:_shadowLayer];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    // shadow
    _shadowLayer.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-1, CGRectGetWidth(self.bounds), 1);
}

#pragma mark - Function
- (NSUInteger)indexForSelected{
    return _selectedIndex;
}

- (void)selecteIndex:(NSUInteger)index{
    
    UIButton *selectBtn = [self.rScrollView viewWithTag:D_kTagOffset + index];
    if (selectBtn) {
        if (index != _selectedIndex && gDefaultSelectIdx != _selectedIndex) {
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
    UIButton *selectedBtn = [self.rScrollView viewWithTag:D_kTagOffset + index];
    if (selectedBtn && selectedBtn.selected) {
        selectedBtn.selected = NO;
        if ([self.delegate respondsToSelector:@selector(crScrollBar:didDeselectedIndex:)]) {
            [self.delegate crScrollBar:self didDeselectedIndex:_selectedIndex];
        }
        _selectedIndex = gDefaultSelectIdx;
    }
}


@end
