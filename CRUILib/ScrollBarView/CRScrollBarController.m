//
//  CRScrollBarController.m
//  CRUILib
//
//  Created by Crazs on 2020/5/14.
//

#import "CRScrollBarController.h"

#define D_scrollBarHei  44
#define F_countCompare(item1, item2)      NSAssert(item1.count == item2.count , @"viewController的元素数量应与scrollBarItems的元素数量相同" );

@interface CRScrollBarController ()<UIScrollViewDelegate,CRScrollBarDelegate>

@property (nonatomic, strong) UIScrollView *rScrollView;

@end

@implementation CRScrollBarController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _rScrollView = [[UIScrollView alloc] init];
        _rScrollView.delegate = self;
        CRScrollBarConfig *barConfig = [CRScrollBarConfig defaultConfig];
        barConfig.padding = UIEdgeInsetsZero;
        _scrollBar = [[CRScrollBar alloc] initWithConfig:barConfig];
        _scrollBar.delegate = self;
        _selectedIndex = _scrollBar.indexForSelected;
    }
    return self;
}

- (instancetype)initWithViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers scrollBarItem:(nonnull NSArray<__kindof CRScrollBarItem *> *)scrollBarItems{
    F_countCompare(viewControllers, scrollBarItems);
    self = [self init];
    if (self) {
        _viewControllers = [viewControllers copy];
        [_scrollBar setMiddleItem:scrollBarItems];
    }
    return self;
}

- (void)viewDidLoad{
    _scrollBar.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), D_scrollBarHei);
    _scrollBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    _scrollBar.selectedColor = UIColor.blueColor;
    [self.view addSubview:_scrollBar];
    
    _rScrollView.frame = CGRectMake(0, D_scrollBarHei, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - D_scrollBarHei);
    _rScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth |UIViewAutoresizingFlexibleHeight;
    _rScrollView.pagingEnabled = YES;
    [self.view addSubview:_rScrollView];
    
    if (0xFFFF == self.selectedIndex) {
        [self setSelectedIndex:0];
    }
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (!self.viewControllers || self.viewControllers.count == 0) {
        return;
    }
    CGSize contentSize = _rScrollView.bounds.size;
    contentSize.width = contentSize.width * self.viewControllers.count;
    _rScrollView.contentSize = contentSize;
    [_rScrollView setContentOffset:CGPointMake(self.selectedIndex * CGRectGetWidth(_rScrollView.bounds), 0) animated:NO];
    [_rScrollView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self showScrollViewPage:self.selectedIndex];
}

#pragma mark - Delegate
#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //FIXME: 实现动画
    NSUInteger index1 = scrollView.contentOffset.x / CGRectGetWidth(scrollView.bounds);
    [self showScrollViewPage:index1];
    if (index1 + 1 < self.viewControllers.count) {
        [self showScrollViewPage:index1 + 1];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    NSLog(@"%d",decelerate);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
}

#pragma mark CRScrollBarDelegate
- (BOOL)crScrollBar:(CRScrollBar *)scrollBar canSelectIndex:(NSUInteger)index{
    return [self canSelectedIndex:index];
}
- (void)crScrollBar:(CRScrollBar *)scrollBar didSelectedIndex:(NSUInteger)index{
    [self setSelectedIndex:index animated:NO settingBar:NO];
}
- (void)crScrollBar:(CRScrollBar *)scrollBar didDeselectedIndex:(NSUInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(crScrollBarController:diddeselectIndex:)]) {
        [self.delegate crScrollBarController:self diddeselectIndex:index];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(crScrollBarController:diddeselectViewController:)]) {
        UIViewController *vc = [_viewControllers objectAtIndex:index];
        [self.delegate crScrollBarController:self diddeselectViewController:vc];
    }
}

#pragma mark - Public
- (void)showScrollViewPage:(NSUInteger)index{
    UIViewController *vc = [_viewControllers objectAtIndex:index];
    [_rScrollView addSubview:vc.view];
    vc.view.frame = CGRectMake(CGRectGetWidth(_rScrollView.bounds) * index, 0, CGRectGetWidth(_rScrollView.bounds), CGRectGetHeight(_rScrollView.bounds));
}

#pragma mark - Private
- (BOOL)canSelectedIndex:(NSUInteger)index{
    if (self.delegate && [self.delegate respondsToSelector:@selector(crScrollBarController:shouldSelectIndex:)] && ![self.delegate crScrollBarController:self shouldSelectIndex:index]) {
        return NO;
    }
    return YES;
}

- (BOOL)canSelectedViewController:(UIViewController *)viewController{
    if (self.delegate && [self.delegate respondsToSelector:@selector(crScrollBarController:shouldSelectViewController::)] && ![self.delegate crScrollBarController:self shouldSelectViewController:viewController]) {
        return NO;
    }
    return YES;
}

#pragma mark - Setter
#pragma mark index
- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    [self setSelectedIndex:selectedIndex animated:NO];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated{
    [self setSelectedIndex:selectedIndex animated:animated settingBar:YES];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated settingBar:(BOOL)settingBar{
    if (selectedIndex > _viewControllers.count) {
        return;
    }else if (![self canSelectedIndex:selectedIndex]){
        return;
    }
    _selectedIndex = selectedIndex;
    
    if (settingBar) {
        [_scrollBar selecteIndex:selectedIndex];
    }
    [_rScrollView setContentOffset:CGPointMake(CGRectGetWidth(_rScrollView.bounds) * selectedIndex, 0) animated:animated];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController{
    [self setSelectedViewController:selectedViewController animated:NO];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController animated:(BOOL)animated{
    if (![_viewControllers containsObject:selectedViewController]) {
        return;
    }else if (![self canSelectedViewController:selectedViewController]){
        return;
    }
    [self setSelectedIndex:[self.viewControllers indexOfObject:selectedViewController] animated:NO];
}

#pragma mark SubControllers
- (void)setViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
             scrollBarItem:(NSArray<__kindof CRScrollBarItem *> *)scrollBarItems
                updatePart:(BOOL)isPart{
    F_countCompare(viewControllers, scrollBarItems);

}

- (void)insertTopViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
                   scrollBarItem:(NSArray<__kindof CRScrollBarItem *> *)scrollBarItems {
    F_countCompare(viewControllers, scrollBarItems);

}

- (void)addRearViewControllers:(NSArray<__kindof UIViewController *> *)viewControllers
                 scrollBarItem:(NSArray<__kindof CRScrollBarItem *> *)scrollBarItems {
    F_countCompare(viewControllers, scrollBarItems);

}

- (void)insertViewControllers:(UIViewController *)viewController
                scrollBarItem:(CRScrollBarItem *)scrollBarItem
                      atIndex:(NSUInteger)index {
    
}

- (void)addViewControllers:(UIViewController *)viewController
             scrollBarItem:(CRScrollBarItem *)scrollBarItem {
    
}


- (void)removeViewControllers:(UIViewController *)viewController{
    
}

- (void)removeScrollBarItem:(CRScrollBarItem *)scrollBarItem{
    
}

- (void)removeTargetIndex:(NSUInteger)index{
    
}

#pragma mark - Getter
@end
