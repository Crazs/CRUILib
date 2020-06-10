//
//  CRScrollSelectBar.h
//  CRUILib
//
//  Created by Crazs on 2020/6/5.
//

#import "CRScrollBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface CRScrollSelectBar : CRScrollBar

@property (nonatomic, strong) CALayer *shadowLayer;

@property (nonatomic, assign, readonly) NSUInteger indexForSelected;    // 如果没有任何选中，返回0xFFFF




/**
 @brief     选中index
 */
- (void)selecteIndex:(NSUInteger)index;
- (void)selecteIndex:(NSUInteger)index animal:(BOOL)animal;
/**
 @brief     取消选中index
 */
- (void)deselectIndex:(NSUInteger)index;
- (void)deselectIndex:(NSUInteger)index animal:(BOOL)animal;


@end

NS_ASSUME_NONNULL_END
