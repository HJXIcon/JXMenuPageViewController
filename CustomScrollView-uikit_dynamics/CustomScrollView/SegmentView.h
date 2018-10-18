//
//  SegmentView.h
//  CustomScrollView
//
//  Created by admin on 2018/10/16.
//  Copyright © 2018年 Ole Begemann. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SegmentView;
@protocol SegmentViewDelegate <NSObject>

- (void)segmentView:(SegmentView *)segmentView didSelectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface SegmentView : UIView
@property (nonatomic, copy) NSArray<NSString *> *titles;
@property (nonatomic, assign) NSInteger selectIndex;
@property (nonatomic, weak) id<SegmentViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
