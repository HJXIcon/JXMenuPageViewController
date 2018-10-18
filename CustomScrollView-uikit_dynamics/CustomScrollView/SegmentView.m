//
//  SegmentView.m
//  CustomScrollView
//
//  Created by admin on 2018/10/16.
//  Copyright © 2018年 Ole Begemann. All rights reserved.
//

#import "SegmentView.h"
#import "UIView+Extension.h"

@interface SegmentView()
@property (nonatomic, strong)NSMutableArray<UILabel *> *titleLabels;
@property (nonatomic, strong) UIView *underLine;

@end
@implementation SegmentView
- (NSMutableArray<UILabel *> *)titleLabels{
    if (_titleLabels == nil) {
        _titleLabels = [NSMutableArray array];
    }
    return _titleLabels;
}
- (UIView *)underLine{
    if (_underLine == nil) {
        _underLine = [[UIView alloc]init];
        _underLine.backgroundColor = [UIColor blueColor];
    }
    return _underLine;
}
- (void)setSelectIndex:(NSInteger)selectIndex{
    _selectIndex = selectIndex;
    
    [UIView animateWithDuration:.25 animations:^{
        self.underLine.centerX = self.titleLabels[selectIndex].centerX;
    }];
}

- (void)setTitles:(NSArray<NSString *> *)titles{
    _titles = titles;
    [self setupUI];
    [self layoutIfNeeded];
}

- (void)setupUI{
    [self.titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *lable = [[UILabel alloc]init];
        lable.font = [UIFont systemFontOfSize:15];
        lable.tag = idx;
        lable.text = obj;
        lable.textAlignment = NSTextAlignmentCenter;
        [self addSubview:lable];
        [self.titleLabels addObject:lable];
        
        lable.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [lable addGestureRecognizer:tap];
    }];
    
    [self addSubview:self.underLine];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat w = self.width/self.titleLabels.count;
    __block CGFloat x = 0;
    CGFloat h = 35;
    CGFloat y = (CGRectGetHeight(self.frame)-h)/2;
    [self.titleLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(x, y, w, h);
        x += w;
    }];
    
    self.underLine.frame = CGRectMake(0, self.height-1, 30, 1);
    self.underLine.centerX = self.titleLabels.firstObject.centerX;
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    UILabel *label = (UILabel *)tap.view;
    [UIView animateWithDuration:.25 animations:^{
       self.underLine.centerX = label.centerX;
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(segmentView:didSelectIndex:)]) {
        [self.delegate segmentView:self didSelectIndex:label.tag];
    }
}
@end
