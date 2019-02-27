//
//  ViewController.m
//  YxlPieChart
//
//  Created by 易小林 on 2019/2/27.
//  Copyright © 2019年 yxl. All rights reserved.
//

#import "ViewController.h"
#import "YxlPieChart.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    YxlPieChart *pieChart = [[YxlPieChart alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, 300)];
    pieChart.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:pieChart];
    [pieChart setDataArray:@[@"0.25", @"0.25", @"0.50"]];
}


@end
