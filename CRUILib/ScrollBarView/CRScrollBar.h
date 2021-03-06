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

- (BOOL)crScrollBar:(CRScrollBar *)scrollBar canSelectIndex:(NSUInteger)index;
/**
 @warning   重复选中相同的index，crScrollBar:didSelectedIndex 也会被重复调用！！！与didDeselectedIndex相反
 */
- (void)crScrollBar:(CRScrollBar *)scrollBar didSelectedIndex:(NSUInteger)index;
/**
 @warning   重复选中相同的index，crScrollBar:didDeselectedIndex 不会被重复调用！！！
 */
- (void)crScrollBar:(CRScrollBar *)scrollBar didDeselectedIndex:(NSUInteger)index;

@end

@interface CRScrollBar : UIView

@property (nonatomic, strong) CRScrollBarConfig *config;

@property (nonatomic, weak) id<CRScrollBarDelegate> delegate;

@property (nonatomic, copy) NSArray<UIBarButtonItem *> *leftItem;
@property (nonatomic, copy) NSArray<UIBarButtonItem *> *rightItem;
@property (nonatomic, copy) NSArray<CRScrollBarItem *> *middleItem;

@property (nonatomic, assign, readonly) NSUInteger indexForSelected;    // 如果没有任何选中，返回0xFFFF

/**
 @brief     创建实例对象
 */
- (instancetype)initWithConfig:(CRScrollBarConfig *)config;

/**
 @brief     选中index
 */
- (void)selecteIndex:(NSUInteger)index;
/**
 @brief     取消选中index
 */
- (void)deselectIndex:(NSUInteger)index;

/**
 @brief     刷新功能，刷新局部
 @note      暂时先不做
 */
- (void)refreshLeftItem;
- (void)refreshRightItem;
- (void)refreshMiddleItem;
- (void)refreshAllItem;

@end

NS_ASSUME_NONNULL_END
