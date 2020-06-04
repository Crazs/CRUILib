//
//  CRScrollBarConfig.m
//  Scroll
//
//  Created by Crazs on 2020/5/9.
//  Copyright © 2020 Crazs. All rights reserved.
//

#import "CRScrollBarConfig.h"

@interface CRScrollBarConfig ()

@property (nonatomic, strong) NSMutableDictionary *attributeDictionary;

@end

@implementation CRScrollBarConfig

+ (instancetype)defaultConfig{
    CRScrollBarConfig *config = [[self alloc] init];
    config.padding = UIEdgeInsetsMake(8, 14, 8, 14);
    config.itemMargin = UIEdgeInsetsZero;
    config.itemPadding = UIEdgeInsetsMake(5, 5, 5, 5);
    config.imageSize = CGSizeMake(28, 28);
    config.titleFont = [UIFont systemFontOfSize:14];
    config.scrollItemInterval = 2;
    config.scrollItemOffset = 8;
    config.scrollPadding = UIEdgeInsetsMake(0, 0, 4, 0);
    return config;
}


- (void)setTitleTextAttributes:(nullable NSDictionary<NSAttributedStringKey,id> *)attributes forState:(UIControlState)state{
    [self.attributeDictionary setObject:attributes forKey:@(state)];
}
- (nullable NSDictionary<NSAttributedStringKey,id> *)titleTextAttributesForState:(UIControlState)state{
    if (nil == _attributeDictionary) {
        return nil;
    }
    return [self.attributeDictionary objectForKey:@(state)];
}
- (NSArray *)allStates{
    return self.attributeDictionary.allKeys;
}

#pragma mark - 懒加载
- (NSDictionary *)attributeDictionary{
    if (_attributeDictionary) {
        return _attributeDictionary;
    }
    _attributeDictionary = [[NSMutableDictionary alloc] initWithCapacity:0];
    return _attributeDictionary;
}

@end
