//
//  ThemeDetailViewController.m
//  album
//
//  Created by seven on 15/7/16.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "ThemeDetailViewController.h"
#import "constants.h"
#import "Html5ViewController.h"
@interface ThemeDetailViewController ()<UIScrollViewDelegate>{

    UIScrollView *contentSV;

}

@end

@implementation ThemeDetailViewController
#pragma mark
#pragma mark view methode;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=RGB(255, 255, 255, 1);
    self.tabBarController.tabBar.hidden=YES;
    
    UIImageView *navigationbarimg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth,kNavHeight)];
    navigationbarimg.backgroundColor=RGB(54, 150, 207,1);
    [self.view addSubview:navigationbarimg];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(0, 20, kWidth, 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    titleText.textAlignment = NSTextAlignmentCenter;
    titleText.font            = [UIFont systemFontOfSize:kNavTitleFont];
    [titleText setText:[self.themeDic objectForKey:@"name"]];
    [self.view addSubview:titleText];
    
    UIButton *photobutton=[[UIButton alloc]initWithFrame:CGRectMake(kWidth-80, 30, 29, 29)];
    [photobutton setImage:[UIImage imageNamed:@"icon-camera"]  forState:UIControlStateNormal];
    [photobutton addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photobutton];

    
    UIButton *addbutton=[[UIButton alloc]initWithFrame:CGRectMake(kWidth-40, 30, 29, 29)];
    [addbutton setImage:[UIImage imageNamed:@"ic_action_stat_share"]  forState:UIControlStateNormal];
    [addbutton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addbutton];
    
    UIButton* backbutton=[[UIButton alloc]initWithFrame:CGRectMake(10, 20, 60, 40)];
    backbutton.titleLabel.font=[UIFont systemFontOfSize:16];
    [backbutton setImage:[UIImage imageNamed:@"back-white"] forState:UIControlStateNormal];
    [backbutton setTitle:@"   返回" forState:UIControlStateNormal];
    [backbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backbutton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [backbutton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backbutton];
    
    contentSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 70, kWidth, kHeight)];
    contentSV.bounces = YES;
    contentSV.pagingEnabled = NO;
    contentSV.delegate = self;
    contentSV.userInteractionEnabled = YES;
    contentSV.showsHorizontalScrollIndicator = NO;
    contentSV.backgroundColor=[UIColor yellowColor];
    [self.view addSubview:contentSV];
    
    
    
    [contentSV setContentSize:CGSizeMake(kWidth, kHeight-70)];
    [contentSV setContentOffset:CGPointMake(0, 0)];

}

#pragma mark
#pragma mark action

-(void)photoAction:(UIButton*)sender{

}

-(void)backAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)shareAction:(UIButton*)sender{
    
    Html5ViewController *nextview=[[Html5ViewController alloc]init];
    [self.navigationController pushViewController:nextview animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
