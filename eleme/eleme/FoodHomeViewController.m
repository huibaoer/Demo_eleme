//
//  FoodHomeViewController.m
//  eleme
//
//  Created by zhanght on 16/5/10.
//  Copyright © 2016年 zhanght. All rights reserved.
//

#import "FoodHomeViewController.h"


#define ScreenHeight            [UIScreen mainScreen].bounds.size.height
#define kNavigationViewHeight   64
#define kTableHeaderViewHeight  56
#define kCategoryCellHeight     50
#define kListCellHeight         70


@interface FoodHomeViewController () <UIScrollViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *categoryArray;
@property (nonatomic, strong) NSArray *dataArray;

//navigationBar
@property (weak, nonatomic) IBOutlet UIView *navigationBarView;
@property (weak, nonatomic) IBOutlet UILabel *navigationTitleLabel;

//headerView
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *shopDescLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcHeaderViewBottomSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lcHeaderViewHeight;

//tableView
@property (weak, nonatomic) IBOutlet UITableView *leftTableView;
@property (weak, nonatomic) IBOutlet UITableView *rightTableView;
@property (nonatomic, assign) BOOL isRelate;//标记左侧table是否跟随右侧table联动

@end

@implementation FoodHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //变量初始化
    self.isRelate = YES;
    self.categoryArray = @[@"好评榜", @"热销榜", @"特色套餐", @"精选热菜", @"爽口凉菜", @"小吃主食", @"酒水饮料", @"水果拼盘", @"养生粥品"];
    
    //tableView
    self.leftTableView.showsVerticalScrollIndicator = NO;
    [self.leftTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"leftCell"];
    self.leftTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, kTableHeaderViewHeight)];
    CGFloat footerHeight = (ScreenHeight - kNavigationViewHeight - self.categoryArray.count*kCategoryCellHeight);
    if (footerHeight > 0) {
        self.leftTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 80, footerHeight)];//保证leftTableView可以滚动
    }
    [self.rightTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"rightCell"];
    self.rightTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, kTableHeaderViewHeight)];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    //当前view隐藏navigationBar
    self.navigationController.navigationBar.hidden = YES;
    self.edgesForExtendedLayout = UIRectEdgeBottom | UIRectEdgeLeft | UIRectEdgeRight;//viewlayout 取消UIRectEdgeTop，上边没有状态栏和导航栏的自动偏移
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //恢复默认navigationBar状态
    self.navigationController.navigationBar.hidden = NO;
}

#pragma mark - tableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.leftTableView) return 1;
    return self.categoryArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.leftTableView) return self.categoryArray.count;
    return arc4random()%10+section+1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) return kCategoryCellHeight;
    return kListCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.rightTableView) return 30;
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.rightTableView) {
        UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 414, 30)];
        header.backgroundColor = [UIColor grayColor];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 400, 30)];
        label.font = [UIFont systemFontOfSize:12];
        label.text = self.categoryArray[section];
        [header addSubview:label];
        return header;
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.leftTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftCell"];
        cell.textLabel.text = self.categoryArray[indexPath.row];
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        return cell;
    } else if (tableView == self.rightTableView) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rightCell"];
        cell.textLabel.text = [NSString stringWithFormat:@"商品%ld", (long)(indexPath.row+1)];
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (tableView == self.rightTableView && self.isRelate) {
        NSInteger topCellSection = [[[tableView indexPathsForVisibleRows] firstObject] section];
        [self.leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:topCellSection inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(UIView *)view forSection:(NSInteger)section {
    if (tableView == self.rightTableView && self.isRelate) {
        NSInteger topCellSection = [[[tableView indexPathsForVisibleRows] firstObject] section];
        [self.leftTableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:topCellSection inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.leftTableView) {
        self.isRelate = NO;
        [self.leftTableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        //点击了左边的cell，让右边的tableView跟着滚动
        [self.rightTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:indexPath.row] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    } else if (tableView == self.rightTableView) {
        //push详情页面
    }
}

#pragma mark - UISCrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    self.isRelate = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //两个tableView同时滚动效果
    if (scrollView == self.rightTableView) {
        if (self.leftTableView.contentOffset.y != scrollView.contentOffset.y) {
            CGPoint leftOffset = CGPointMake(0, MIN(kTableHeaderViewHeight, scrollView.contentOffset.y));
            self.leftTableView.contentOffset = leftOffset;
        }
    }
    if (scrollView == self.leftTableView) {
        if (scrollView.contentOffset.y < kTableHeaderViewHeight) {
            if (self.rightTableView.contentOffset.y != scrollView.contentOffset.y) {
                self.rightTableView.contentOffset = scrollView.contentOffset;
            }
        } else if (scrollView.contentOffset.y >= kTableHeaderViewHeight && self.rightTableView.contentOffset.y < kTableHeaderViewHeight) {
            self.rightTableView.contentOffset = scrollView.contentOffset;
        }
    }
    
    //headerView效果
    self.lcHeaderViewBottomSpace.constant = self.leftTableView.contentOffset.y - kTableHeaderViewHeight;
    if (scrollView.contentOffset.y < 0) {
        self.lcHeaderViewHeight.constant = 120 + fabs(scrollView.contentOffset.y);
    }
    
    //navigationBarView效果
    CGFloat alpha;
    if (scrollView.contentOffset.y <= 0) {
        alpha = 0;
    } else if (scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < kTableHeaderViewHeight) {
        alpha = scrollView.contentOffset.y / kTableHeaderViewHeight;
    } else {
        alpha = 1;
    }
    self.navigationBarView.backgroundColor = [self.navigationBarView.backgroundColor colorWithAlphaComponent:alpha];
}


@end
