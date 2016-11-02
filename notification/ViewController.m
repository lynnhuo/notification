//
//  ViewController.m
//  notification
//
//  Created by 刘炎 on 2016/10/26.
//  Copyright © 2016年 Lynn. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic,strong)UILabel *文本;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.文本 = [[UILabel alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.文本.text = @"这是文本";
    [self.view addSubview:self.文本];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
