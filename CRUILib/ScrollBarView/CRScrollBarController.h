//
//  CRScrollBarController.h
//  CRUILib
//
//  Created by Crazs on 2020/5/14.
//

#import <UIKit/UIKit.h>
#import "CRScrollBar.h"

NS_ASSUME_NONNULL_BEGIN

@protocol CRScrollBarControllerDelegate <NSObject>



@end

@interface CRScrollBarController : UIViewController

@property (nonatomic, strong) CRScrollBar *scrollBar;
@property (nonatomic, weak) id<CRScrollBarControllerDelegate> delegate;

@property(nullable, nonatomic,copy) NSArray<__kindof UIViewController *> *viewControllers;

@property(nullable, nonatomic, assign) __kindof UIViewController *selectedViewController;
@property(nonatomic) NSUInteger selectedIndex;

- (instancetype)initWithViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers;

@end

NS_ASSUME_NONNULL_END
