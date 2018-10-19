//
//  ScrollViewController.m
//  CustomScrollView
//
//  Created by admin on 2018/10/16.
//  Copyright © 2018年 Ole Begemann. All rights reserved.
//

#import "ScrollViewController.h"
#import "CustomScrollView.h"
#import "SegmentView.h"
#import "UIView+Extension.h"
#import "CategoryListView.h"
#import "FoodListView.h"
#import "SummaryListView.h"
#import "HeaderView.h"
#import "CSCDynamicItem.h"
#import "JXCustomScrollView.h"
#import "JXScrollTopWindow.h"


static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension) {
    
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0.0f ? -result : result;
}


// >>>>>> 适配iOS 11、iPhone X
#pragma mark -  *** 适配iOS 11、iPhone X

#define isIOS11 [[UIDevice currentDevice].systemVersion floatValue] >= 11

/// 底部宏，吃一见长一智吧，别写数字了
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define iPhone5s ([UIScreen mainScreen].bounds.size.width>=320.0f && [UIScreen mainScreen].bounds.size.height>=568.0f && IS_IPHONE)
#define iPhoneX ([UIScreen mainScreen].bounds.size.width>=375.0f && [UIScreen mainScreen].bounds.size.height>=812.0f && IS_IPHONE)

// 状态栏高度
#define TP_StatusBarHeight (iPhoneX ? 44.f : 20.f)
// 导航条高度
#define TP_NavigationBarHeight  44.f


// tabbar 高度
#define TP_TabbarHeight (iPhoneX ? (49.f+34.f) : 49.f)
// tabbarSafe
#define TP_TabbarSafeBottomMargin (iPhoneX ? 34.f : 0.f)


// 导航栏默认高度
#define  TP_StatusBarAndNavigationBarHeight  (iPhoneX ? 88.f : 64.f)

#define KScreenW [UIScreen mainScreen].bounds.size.width
#define KScreenH [UIScreen mainScreen].bounds.size.height

#define KMaxOffsetY  120

@interface ScrollViewController ()<UIScrollViewDelegate,SegmentViewDelegate,UIDynamicAnimatorDelegate> {
    
    CGFloat currentScorllY;
    BOOL isEndScorll; // 是否滚动停止了
    NSMutableArray *tableViews;
}
@property (nonatomic, strong) UIView *containerView;
// 仅仅左右滑动
@property (nonatomic, strong) JXCustomScrollView *scollView;
@property (nonatomic, strong) SegmentView *segmentView;
@property (nonatomic, strong) HeaderView *headerView;


@property (nonatomic, assign) CGFloat tableViewContentOffsetStartY;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) CSCDynamicItem *dynamicItem;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, weak) UIAttachmentBehavior *springBehavior;

@property (nonatomic, strong) JXScrollTopWindow *scrollTopWindow;
@property (nonatomic) CGPoint lastYInBounds;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupUI];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    [self.containerView addGestureRecognizer:pan];
    
    self.dynamicItem = [[CSCDynamicItem alloc] init];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.containerView];
    self.animator.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    _scrollTopWindow.hidden = YES;
}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _scrollTopWindow.hidden = NO;
}

- (void)dealloc{
    _scrollTopWindow = nil;
}
#pragma mark - *** Private Method
- (void)_setupUI{
    
    _scrollTopWindow = [[JXScrollTopWindow alloc]init];
    _scrollTopWindow.frame = CGRectMake(0, 0, [UIApplication sharedApplication].statusBarFrame.size.width, [UIApplication sharedApplication].statusBarFrame.size.height);
    _scrollTopWindow.hidden = NO;
    _scrollTopWindow.windowLevel = UIWindowLevelStatusBar+1;
    _scrollTopWindow.backgroundColor = [UIColor clearColor];
    __weak typeof(self) weak_self = self;
    _scrollTopWindow.ScrollTopBlock = ^{
        [weak_self.tableView setContentOffset:CGPointZero animated:YES];
    };
    
    self.containerView = [[UIView alloc]init];
    self.containerView.frame = CGRectMake(0, TP_StatusBarAndNavigationBarHeight, KScreenW, KScreenH+KMaxOffsetY+44);
    self.containerView.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    [self.view addSubview:self.containerView];
    
    self.headerView = [[HeaderView alloc]init];
    self.headerView.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    self.headerView.frame = CGRectMake(0, 0, KScreenW, KMaxOffsetY);
    [self.containerView addSubview:self.headerView];
    
    
    self.segmentView = [[SegmentView alloc]init];
    self.segmentView.titles = @[@"点餐",@"评价",@"商家"];
    self.segmentView.frame = CGRectMake(0, CGRectGetMaxY(self.headerView.frame), KScreenW, 44);
    self.segmentView.delegate = self;
    [self.containerView addSubview:self.segmentView];
    
    self.scollView = [[JXCustomScrollView alloc]init];
    self.scollView.showsVerticalScrollIndicator = NO;
    self.scollView.showsHorizontalScrollIndicator = NO;
    self.scollView.bounces = NO;
    self.scollView.delegate = self;
    self.scollView.pagingEnabled = YES;
    self.scollView.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    self.scollView.frame = CGRectMake(0, CGRectGetMaxY(self.segmentView.frame), KScreenW, KScreenH-44-TP_TabbarHeight-TP_StatusBarAndNavigationBarHeight);
    [self.containerView addSubview:self.scollView];
    self.scollView.contentSize = CGSizeMake(KScreenW*3,0);
    
    [self _addChildViewControllers];
}

- (void)_addChildViewControllers{
 
    tableViews = [NSMutableArray array];
    
    CategoryListView *categoryVc = [[CategoryListView alloc]init];
    categoryVc.view.frame = CGRectMake(0, 0, self.scollView.width, self.scollView.height);
    [self addChildViewController:categoryVc];
    [self.scollView addSubview:categoryVc.view];
    self.tableView = categoryVc.tableView;
    [tableViews addObject:categoryVc.tableView];
    
    FoodListView *foodListVc = [[FoodListView alloc]init];
    foodListVc.view.frame = CGRectMake(self.scollView.width, 0, self.scollView.width, self.scollView.height);
    [self addChildViewController:foodListVc];
    [self.scollView addSubview:foodListVc.view];
    [tableViews addObject:foodListVc.tableView];
    
    SummaryListView *summaryVc = [[SummaryListView alloc]init];
    summaryVc.view.frame = CGRectMake(self.scollView.width*2, 0, self.scollView.width, self.scollView.height);
    [self addChildViewController:summaryVc];
    [self.scollView addSubview:summaryVc.view];
    [tableViews addObject:summaryVc.tableView];

}
- (void)_dealSpringBehavior:(CGFloat)detal hoverY:(CGFloat)hoverY{
    
    BOOL outSideTableViewContentSize = NO;
    if ((self.tableView.contentOffset.y == 0 && hoverY == TP_StatusBarAndNavigationBarHeight)|| self.tableView.contentOffset.y > self.tableView.contentSize.height - self.tableView.height) {
        outSideTableViewContentSize = YES;
        NSLog(@" hoverY --------------- %f",hoverY);
    }
    
    if (outSideTableViewContentSize && (!self.springBehavior && self.animator)) {
        CGPoint target = CGPointMake(self.containerView.centerX, hoverY+self.containerView.centerY);
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.dynamicItem attachedToAnchor:target];
        // Has to be equal to zero, because otherwise the bounds.origin wouldn't exactly match the target's position.
        springBehavior.length = 0;
        // These two values were chosen by trial and error.
        springBehavior.damping = 2;
        springBehavior.frequency = 1;
        [self.animator addBehavior:springBehavior];
        self.springBehavior = springBehavior;
        NSLog(@" --------------- target:%@",NSStringFromCGPoint(target));
    }
    
    
}


#pragma mark - *** Actions
- (void)panAction:(UIPanGestureRecognizer *)panGestureRecognizer{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
           [panGestureRecognizer setTranslation:CGPointZero inView:self.containerView];
            [self.animator removeAllBehaviors];
            currentScorllY = self.tableView.contentOffset.y;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            
            CGPoint transPoint = [panGestureRecognizer translationInView:self.containerView];
            // 往上滑为负数，往下滑为正数
            CGFloat detalY = transPoint.y;
//            NSLog(@"currentScorllY -- %f",currentScorllY);
//            NSLog(@"detal +++ %f",detal);
            
            // 往上滑
            if (detalY < 0) {
                if (self.containerView.y > -KMaxOffsetY+TP_StatusBarAndNavigationBarHeight) {
                    self.containerView.y += detalY;
                }else{
                    currentScorllY -= detalY;
                    
                    if (self.tableView.contentSize.height >= self.scollView.height) {
                        if (currentScorllY >= self.tableView.contentSize.height - self.scollView.height) {
                            currentScorllY = self.tableView.contentSize.height - self.scollView.height;
                        }
                    }else{
                        currentScorllY = 0;
                    }
                    
                    [self.tableView setContentOffset:CGPointMake(0, currentScorllY)];
//                    self.containerView.y = - KMaxOffsetY+TP_StatusBarAndNavigationBarHeight;
                    
                    /// 弹性效果
                    self.containerView.y += detalY;
                    [self _dealSpringBehavior:detalY hoverY:- KMaxOffsetY+TP_StatusBarAndNavigationBarHeight];
                }
                
            }
            else{// 往下f滑
                
                if (currentScorllY>0) {
                    currentScorllY -= detalY;
                    if (currentScorllY <= 0) {
                        currentScorllY = 0;
                    }
                    [self.tableView setContentOffset:CGPointMake(0, currentScorllY)];
                    
                }else{
                    self.containerView.y = self.containerView.y + detalY;
                    if (self.containerView.y >= TP_StatusBarAndNavigationBarHeight) {
//                        self.containerView.y = TP_StatusBarAndNavigationBarHeight;
                        
                        
                        /// 弹性效果
                        [self _dealSpringBehavior:detalY hoverY:TP_StatusBarAndNavigationBarHeight];
                    }
                }
            }
            
            
           [panGestureRecognizer setTranslation:CGPointZero inView:self.containerView];
            
            
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            self.dynamicItem.center = self.view.bounds.origin;
            //velocity是在手势结束的时候获取的竖直方向的手势速度
            CGPoint velocity = [panGestureRecognizer velocityInView:self.containerView];
            
            UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.dynamicItem]];
            [inertialBehavior addLinearVelocity:CGPointMake(0, velocity.y) forItem:self.dynamicItem];
            // 通过尝试取2.0比较像系统的效果(线速度阻尼)
            inertialBehavior.resistance = 2.8;
            __block CGPoint lastCenter = CGPointZero;
            __weak typeof(self) weakSelf = self;
            inertialBehavior.action = ^{
                isEndScorll = NO;
                /// 惯性
                //得到每次移动的距离
                CGFloat currentY = weakSelf.dynamicItem.center.y - lastCenter.y;
                lastCenter = weakSelf.dynamicItem.center;
                [self _dealScrolDynamic:currentY];
//                NSLog(@"currentY:%f lastCenter:%@",currentY,NSStringFromCGPoint(lastCenter));
            };
            [self.animator addBehavior:inertialBehavior];
            self.decelerationBehavior = inertialBehavior;
        }
            break;
            
        default:
            break;
    }
    
    //保证每次只是移动的距离，不是从头一直移动的距离
    [panGestureRecognizer setTranslation:CGPointZero inView:self.containerView];
}


- (void)_dealScrolDynamic:(CGFloat)detal{
    
    // 往上滑
    if (detal < 0) {
        if (self.containerView.y > -KMaxOffsetY+TP_StatusBarAndNavigationBarHeight) {
            self.containerView.y += detal;
            
        }else{
            currentScorllY -= detal;
            
            if (self.tableView.contentSize.height >= self.scollView.height) {
                if (currentScorllY >= self.tableView.contentSize.height - self.scollView.height) {
                    currentScorllY = self.tableView.contentSize.height - self.scollView.height;
                    isEndScorll = YES;
                    
                }
            }else{
                currentScorllY = 0;
                isEndScorll = YES;
                
            }
            
            [self.tableView setContentOffset:CGPointMake(0, currentScorllY)];
            self.containerView.y = - KMaxOffsetY+TP_StatusBarAndNavigationBarHeight;
        }
        
    }
    else{// 往下f滑
        
        if (currentScorllY>0) {
            currentScorllY -= detal;
            if (currentScorllY <= 0) {
                currentScorllY = 0;
                
            }
            [self.tableView setContentOffset:CGPointMake(0, currentScorllY)];
            
        }else{
            self.containerView.y = self.containerView.y + detal;
            if (self.containerView.y >= TP_StatusBarAndNavigationBarHeight) {
                self.containerView.y = TP_StatusBarAndNavigationBarHeight;
                isEndScorll = YES;
                
            }
        }
    }

    if (isEndScorll) {
        [self.animator removeBehavior:self.decelerationBehavior];
    }
   
    
}


#pragma mark - *** UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset/KScreenW;
    self.segmentView.selectIndex = index;

    self.tableView = tableViews[index];
    currentScorllY = self.tableView.contentOffset.y;
    [self.animator removeBehavior:self.decelerationBehavior];
}

#pragma mark - *** SegmentViewDelegate
- (void)segmentView:(SegmentView *)segmentView didSelectIndex:(NSInteger)index{
    [self.scollView setContentOffset:CGPointMake(KScreenW*index, 0) animated:YES];
    
    self.tableView = tableViews[index];
    currentScorllY = self.tableView.contentOffset.y;
    [self.animator removeBehavior:self.decelerationBehavior];
}


#pragma mark - *** UIDynamicAnimatorDelegate
/// 误触发tableView的-tableView:didSelectRowAtIndexPath:indexPath协议方法, 导致很容易Push到下一个页面, 很影响使用
- (void)dynamicAnimatorWillResume:(UIDynamicAnimator *)animator{
    self.tableView.userInteractionEnabled = YES;
}
- (void)dynamicAnimatorDidPause:(UIDynamicAnimator *)animator{
    self.tableView.userInteractionEnabled = YES;
}
@end
