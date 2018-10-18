//
//  CategoryListView.m
//  CustomScrollView
//
//  Created by admin on 2018/10/16.
//  Copyright © 2018年 Ole Begemann. All rights reserved.
//

#import "CategoryListView.h"

@interface CategoryListView ()<UITableViewDataSource>


@end

@implementation CategoryListView

- (UITableView *)tableView{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.tableFooterView = [[UIView alloc]init];
        _tableView.scrollsToTop = NO;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - *** UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 38;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    if (indexPath.row == 0 ) {
        cell.contentView.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];;
    }
    cell.textLabel.text = [NSString stringWithFormat:@"Category == %ld",indexPath.row];
    return cell;
}


@end
