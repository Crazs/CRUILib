//
//  CRScrollBarConfig.h
//  Scroll
//
//  Created by Crazs on 2020/5/9.
//  Copyright © 2020 Crazs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @brief 配置文件
 */
@interface CRScrollBarConfig : NSObject

+ (instancetype)defaultConfig;

@property (nonatomic, assign) UIEdgeInsets padding;
// 仅对左右两个的按钮生效，top和bottomb属性不生效
@property (nonatomic, assign) UIEdgeInsets itemMargin;
@property (nonatomic, assign) UIEdgeInsets itemPadding;

@property (nonatomic, assign) CGFloat scrollItemInterval;   // scroll item 的间隔
@property (nonatomic, assign) UIEdgeInsets scrollPadding;
// 增加 scroll item 的响应范围，上下范围依赖view的高度和padding属性
@property (nonatomic, assign) CGFloat scrollItemOffset;

@property (nonatomic, assign) CGSize imageSize;     // 图片尺寸
@property (nonatomic, strong) UIFont *titleFont;    // 文字样式

/**
 将样式的全局设置，移动到了config文件中，实现了不同ScrollBar自定比不同样式功能
 */
- (void)setTitleTextAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state;
- (nullable NSDictionary<NSAttributedStringKey,id> *)titleTextAttributesForState:(UIControlState)state;
- (NSArray *)allStates;

@end

NS_ASSUME_NONNULL_END
