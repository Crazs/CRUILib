//
//  CRScrollSelectedBar.m
//  CRUILib
//
//  Created by Crazs on 2020/6/5.
//

#import "CRScrollSelectedBar.h"

@interface CRScrollBar (CRPrivate)
- (void)createScrollView;
@end

@implementation CRScrollSelectedBar

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

@end
