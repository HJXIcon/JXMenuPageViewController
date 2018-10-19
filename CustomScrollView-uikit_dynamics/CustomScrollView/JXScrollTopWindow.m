//
//  JXScrollTopWindow.m
//  CustomScrollView
//
//  Created by admin on 2018/10/19.
//  Copyright © 2018年 Ole Begemann. All rights reserved.
//

#import "JXScrollTopWindow.h"

@implementation JXScrollTopWindow
+ (instancetype)shareWindow{
    static JXScrollTopWindow *window;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        window = [[JXScrollTopWindow alloc]init];
    });
   
    return window;
}
/*
还有一个很常见的问题, 点击状态栏, 正常情况下系统能够将ScrollView滚动到顶部, 而在一个Window中有多个ScrollView的时候, 它是不一定成功的. 正确的解决方案应该是将当前页面需要响应系统statusBar点击的ScrollView的scrollsToTop设置为YES, 其他都设置为NO, 并且scrollsToTop为YES的只能有一个, 这种情况下理论上是可以work的. 但是在解决第一个问题的时候, 导致了这种解决方法有时候不成功. 因为发现在一个UIScrollView的userInteractionEnabled == NO的时候, 状态栏点击返回顶部效果是无效的(比如正在惯性滚动的时候, 状态还是NO, 这个时候点击statusBar); 加上在最左边的页面有两个tableView需要同时滚动到顶部. 只能换个解决方案. 子类化了全局的UIWindow, 重写它的-pointInside:withEvent:, 在statusBar区域被点击的时候发出通知, 监听到后手动设置contentOffset到0.
*/
- (instancetype)init{
    if (self = [super init]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
        [self addGestureRecognizer:tap];
    }
    return self;
   
}

- (void)tapAction{
    if(self.ScrollTopBlock) self.ScrollTopBlock();
}
@end
