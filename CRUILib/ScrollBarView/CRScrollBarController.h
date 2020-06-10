//
//  CRScrollBarController.h
//  CRUILib
//
//  Created by Crazs on 2020/5/14.
//

#import <UIKit/UIKit.h>
#import "CRScrollSelectBar.h"

NS_ASSUME_NONNULL_BEGIN
@class CRScrollBarController;
@protocol CRScrollBarControllerDelegate <NSObject>
@optional
- (BOOL)crScrollBarController:(CRScrollBarController *)scrollBarController
   shouldSelectViewController:(UIViewController *)viewController;
- (void)crScrollBarController:(UITabBarController *)tabBarController
      didSelectViewController:(UIViewController *)viewController;
- (void)crScrollBarController:(UITabBarController *)tabBarController
    diddeselectViewController:(UIViewController *)viewController;


- (BOOL)crScrollBarController:(CRScrollBarController *)scrollBarController
            shouldSelectIndex:(NSUInteger *)index;
- (void)crScrollBarController:(UITabBarController *)tabBarController
               didSelectIndex:(NSUInteger)index;
- (void)crScrollBarController:(UITabBarController *)tabBarController
             diddeselectIndex:(NSUInteger *)index;


@end

@interface CRScrollBarController : UIViewController

@property (nonatomic, strong) CRScrollSelectBar *scrollBar;
@property (nonatomic, weak) id<CRScrollBarControllerDelegate> delegate;

@property (nonatomic, copy) NSArray<__kindof UIViewController *> *viewControllers;

@property (nonatomic, assign) __kindof UIViewController *selectedViewController;
@property (nonatomic, assign) NSUInteger selectedIndex;

- (instancetype)initWithViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
                          scrollBarItem:(NSArray<__kindof CRScrollBarItem *> *)scrollBarItems;

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)setSelectedViewController:(__kindof UIViewController * _Nullable)selectedViewController animated:(BOOL)animated;

/**
 @brief     局部更新，如果已经包含viewcontroller，使用旧的，不创建新的
 */
- (void)setViewControllers:(NSArray<__kindof UIViewController *> * _Nullable)viewControllers updatePart:(BOOL)isPart;

@end

/**
 @brief controllers 的更新
 @warning   更新方法调用暂时无效果
 */
@interface CRScrollBarController (Update)
/**
 @brief     局部更新，如果已经包含viewcontroller，使用旧的，不创建新的
 */
- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
             scrollBarItem:(NSArray<__kindof CRScrollBarItem *> *)scrollBarItems
                updatePart:(BOOL)isPart;

/**
 @brief     头部批量插入
 */
- (void)insertTopViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
                   scrollBarItem:(NSArray<__kindof CRScrollBarItem *> *)scrollBarItems;

/**
 @brief     尾部批量添加
 */
- (void)addRearViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
                 scrollBarItem:(NSArray<__kindof CRScrollBarItem *> *)scrollBarItems;

/**
 @brief     指定位置添加
 */
- (void)insertViewControllers:(UIViewController *)viewController
                scrollBarItem:(CRScrollBarItem *)scrollBarItem
                      atIndex:(NSUInteger)index;

/**
 @brief     添加一个
 */
- (void)addViewControllers:(UIViewController *)viewController
             scrollBarItem:(CRScrollBarItem *)scrollBarItem;

/**
 @brief     根据controller移除
 */
- (void)removeViewControllers:(UIViewController *)viewController;

/**
 @brief     根据scrollItem移除
 */
- (void)removeScrollBarItem:(CRScrollBarItem *)scrollBarItem;

/**
 @brief     根据index移除
 */
- (void)removeTargetIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
