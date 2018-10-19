//
//  JXCustomScrollView.m
//  CustomScrollView
//
//  Created by admin on 2018/10/19.
//  Copyright © 2018年 Ole Begemann. All rights reserved.
//

#import "JXCustomScrollView.h"

@implementation JXCustomScrollView
// 当tableView在UIKit Dynamics的作用下滚动时, 或者是快速上下滑动的时候, 很容易触发左右滑动的ScrollView切换页面. 解决方案比较tricky: 自定义了UIScrollView的子类, 在子类中将gestureRecognizerShouldBegin:重写, 对于panGestureRecognizer的情况, 在它的水平速度和垂直速度的夹角在一定范围内强制返回NO. 这样就大大减小了误触发左右滚动的操作. 但是还是希望有更好的解决方案.
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGFloat currentY = [recognizer translationInView:self].y;
        CGFloat currentX = [recognizer translationInView:self].x;
        
        if (currentY == 0.0) {
            return YES;
        } else {
            if (fabs(currentX)/currentY >= 5.0) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}
@end
