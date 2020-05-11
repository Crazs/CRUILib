//
//  CRScrollBarItem.m
//  Scroll
//
//  Created by Crazs on 2020/5/9.
//  Copyright © 2020 Crazs. All rights reserved.
//

#import "CRScrollBarItem.h"

@implementation CRScrollBarItem

@synthesize title;
@synthesize image;

- (instancetype)initWithTitle:(NSString *)title{
    self = [super init];
    if (self) {
        self.title = title;
    }
    return self;
}

- (instancetype)initWithImage:(UIImage *)image{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

@end


@implementation CRCustomBarItem

@synthesize title;
@synthesize image;

- (instancetype)initWithImage:(nullable UIImage *)image
                        style:(UIBarButtonItemStyle)style
                       target:(nullable id)target
                       action:(nullable SEL)action{
    self = [super init];
    if (self) {
        self.image = image;
        self.target = target;
        self.action = action;
    }
    return self;
}

- (instancetype)initWithTitle:(nullable NSString *)title
                        style:(UIBarButtonItemStyle)style
                       target:(nullable id)target
                       action:(nullable SEL)action{
    self = [super init];
    if (self) {
        self.title = title;
        self.target = target;
        self.action = action;
    }
    return self;
}

@end
