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

@interface ScrollViewController ()<UIScrollViewDelegate,SegmentViewDelegate,UIGestureRecognizerDelegate> {
    
    CGFloat currentScorllY;
    UIView *toolView;
    NSMutableArray *tableArray;
    __block BOOL isVertical;//是否是垂直
    NSMutableArray *tableViews;
}
@property (nonatomic, strong) UIView *containerView;
// 仅仅左右滑动
@property (nonatomic, strong) UIScrollView *scollView;
@property (nonatomic, strong) SegmentView *segmentView;
@property (nonatomic, strong) HeaderView *headerView;


@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat tableViewContentOffsetStartY;
@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) CSCDynamicItem *dynamicItem;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, weak) UIAttachmentBehavior *springBehavior;
@end

@implementation ScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _setupUI];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
    pan.delegate = self;
    [self.containerView addGestureRecognizer:pan];
    
    self.dynamicItem = [[CSCDynamicItem alloc] init];
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
}

- (void)_setupUI{
    
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
    
    self.scollView = [[UIScrollView alloc]init];
    self.scollView.showsVerticalScrollIndicator = NO;
    self.scollView.showsHorizontalScrollIndicator = NO;
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

#pragma mark - *** Actions
- (void)panAction:(UIPanGestureRecognizer *)panGestureRecognizer{
    switch (panGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
           [panGestureRecognizer setTranslation:CGPointZero inView:self.containerView];
            self.startY = [panGestureRecognizer translationInView:self.containerView].y;
            [self.animator removeAllBehaviors];
            currentScorllY = self.tableView.contentOffset.y;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            
            // 往上滑为负数，往下滑为正数
            CGFloat currentY = [panGestureRecognizer translationInView:self.containerView].y;
            CGFloat detal = currentY - self.startY;
    
            NSLog(@"currentScorllY -- %f",currentScorllY);
            NSLog(@"detal +++ %f",detal);
            
            // 往上滑
            if (currentY < 0) {
                if (self.containerView.y > -KMaxOffsetY+TP_StatusBarAndNavigationBarHeight) {
                    self.containerView.y += detal;
                }else{
                    currentScorllY -= detal;
                    
                    if (self.tableView.contentSize.height >= self.scollView.height) {
                        if (currentScorllY >= self.tableView.contentSize.height - self.scollView.height) {
                            currentScorllY = self.tableView.contentSize.height - self.scollView.height;
                        }
                    }else{
                        currentScorllY = 0;
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
            // 通过尝试取2.0比较像系统的效果
            inertialBehavior.resistance = 2.0;
            __block CGPoint lastCenter = CGPointZero;
            __weak typeof(self) weakSelf = self;
            inertialBehavior.action = ^{
                //得到每次移动的距离
                CGFloat currentY = weakSelf.dynamicItem.center.y - lastCenter.y;
                lastCenter = weakSelf.dynamicItem.center;
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

#pragma mark - *** UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset/KScreenW;
    self.segmentView.selectIndex = index;

    self.tableView = tableViews[index];
    currentScorllY = self.tableView.contentOffset.y;
}

#pragma mark - *** SegmentViewDelegate
- (void)segmentView:(SegmentView *)segmentView didSelectIndex:(NSInteger)index{
    [self.scollView setContentOffset:CGPointMake(KScreenW*index, 0) animated:YES];
    
    self.tableView = tableViews[index];
    currentScorllY = self.tableView.contentOffset.y;
}


@end
