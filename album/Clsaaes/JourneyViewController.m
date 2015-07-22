//
//  JourneyViewController.m
//  album
//
//  Created by seven on 15/7/15.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "JourneyViewController.h"
#import "constants.h"
#import "AddJourneyViewController.h"
#import "JourneyDetailViewController.h"
#import "Html5ViewController.h"
@interface JourneyViewController ()

@end

@implementation JourneyViewController
-(void)viewWillAppear:(BOOL)animated{
    
    self.tabBarController.tabBar.hidden=NO;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=RGB(255, 255, 255, 1);
    
    UIImageView *navigationbarimg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth,kNavHeight)];
    navigationbarimg.backgroundColor=RGB(54, 150, 207,1);
    [self.view addSubview:navigationbarimg];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(0, 20, kWidth, 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    titleText.textAlignment = NSTextAlignmentCenter;
    titleText.font            = [UIFont systemFontOfSize:kNavTitleFont];
    [titleText setText:@"旅行拍"];
    [self.view addSubview:titleText];
    UIButton *photobutton=[[UIButton alloc]initWithFrame:CGRectMake(20, 30, 29, 29)];
    [photobutton setImage:[UIImage imageNamed:@"icon-camera"]  forState:UIControlStateNormal];
    [photobutton addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photobutton];
    
    UIButton *addbutton=[[UIButton alloc]initWithFrame:CGRectMake(kWidth-40, 30, 29, 29)];
    [addbutton setImage:[UIImage imageNamed:@"icon-add"]  forState:UIControlStateNormal];
    [addbutton addTarget:self action:@selector(addAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addbutton];
    
    
}
-(IBAction)journeydetailAction{
    
    JourneyDetailViewController *nextview=[[JourneyDetailViewController alloc]init];
    [self.navigationController pushViewController:nextview animated:YES];
    

}

-(void)addAction:(UIButton*)sender{
    
    
}

-(void)photoAction:(UIButton*)sender{
    
    
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
