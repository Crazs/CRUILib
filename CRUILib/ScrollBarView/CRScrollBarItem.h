//
//  CRScrollBarItem.h
//  Scroll
//
//  Created by Crazs on 2020/5/9.
//  Copyright © 2020 Crazs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CRScrollBarItem : UIBarItem

- (instancetype)initWithTitle:(nullable NSString *)title;
- (instancetype)initWithImage:(nullable UIImage *)image;

@end

@interface CRCustomBarItem : UIBarItem

- (instancetype)initWithImage:(nullable UIImage *)image
                        style:(UIBarButtonItemStyle)style
                       target:(nullable id)target
                       action:(nullable SEL)action;

- (instancetype)initWithTitle:(nullable NSString *)title
                        style:(UIBarButtonItemStyle)style
                       target:(nullable id)target
                       action:(nullable SEL)action;

@property(nonatomic)         CGFloat              width;

@property(nullable, nonatomic)         SEL                  action;
@property(nullable, nonatomic,weak)    id                   target;

@end

NS_ASSUME_NONNULL_END
