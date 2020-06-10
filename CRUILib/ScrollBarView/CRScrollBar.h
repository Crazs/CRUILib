//
//  CRScrollBar.h
//  Scroll
//
//  Created by Crazs on 2020/5/9.
//  Copyright © 2020 Crazs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CRScrollBarConfig.h"
#import "CRScrollBarItem.h"

NS_ASSUME_NONNULL_BEGIN

@class CRScrollBar;
@protocol CRScrollBarDelegate <NSObject>
@optional
- (BOOL)crScrollBar:(CRScrollBar *)scrollBar canSelectIndex:(NSUInteger)index;
/**
 @warning   重复选中相同的index，crScrollBar:didSelectedIndex 也会被重复调用！！！与didDeselectedIndex相反
 */
- (void)crScrollBar:(CRScrollBar *)scrollBar didSelectedIndex:(NSUInteger)index;
/**
 @warning   重复取消选中相同的index，crScrollBar:didDeselectedIndex 不会被重复调用！！！
 */
- (void)crScrollBar:(CRScrollBar *)scrollBar didDeselectedIndex:(NSUInteger)index;

@end

@interface CRScrollBar : UIView

@property (nonatomic, strong) CRScrollBarConfig *config;

@property (nonatomic, weak) id<CRScrollBarDelegate> delegate;

@property (nonatomic, copy) NSArray<UIBarButtonItem *> *leftItems;
@property (nonatomic, copy) NSArray<UIBarButtonItem *> *rightItems;
@property (nonatomic, copy) NSArray<CRScrollBarItem *> *middleItems;

@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIColor *selectedColor;

/**
 @brief     创建实例对象
 */
- (instancetype)initWithConfig:(CRScrollBarConfig *)config;

/**
 @brief     刷新功能，刷新局部
 */
- (void)refreshLeftItem;
- (void)refreshRightItem;
- (void)refreshMiddleItem;
- (void)refreshAllItem;

@end

NS_ASSUME_NONNULL_END
