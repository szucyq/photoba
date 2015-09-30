//
//  SettingViewController.m
//  album
//
//  Created by seven on 15/7/15.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "SettingViewController.h"
#import "constants.h"
#import "HelpViewController.h"
#import "SettingDetailViewController.h"
@interface SettingViewController ()<UITableViewDataSource,UITableViewDelegate>{
    
    UITableView*listTV;
    
}


@end

@implementation SettingViewController
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
    [titleText setText:@"设置"];
    [self.view addSubview:titleText];
    
    UIImageView *touxiangimg=[[UIImageView alloc]initWithFrame:CGRectMake((kWidth-120)/2, 100, 120,120)];
    [touxiangimg setImage:[UIImage imageNamed:@"globe"]];
    [self.view addSubview:touxiangimg];
    
    UILabel * banbenText = [[UILabel alloc] initWithFrame: CGRectMake(0, 260, kWidth, 30)];
    banbenText.backgroundColor = [UIColor clearColor];
    banbenText.textColor=RGB(67, 67, 67, 1);
    banbenText.textAlignment = NSTextAlignmentCenter;
    banbenText.font            = [UIFont systemFontOfSize:16.0];
    [banbenText setText:@"版本V1.0.0"];
    [self.view addSubview:banbenText];
    
    listTV=[[UITableView alloc]initWithFrame:CGRectMake(0, 300, kWidth,100) style:UITableViewStylePlain];
    listTV.delegate  =self;
    listTV.dataSource=self;
    listTV.backgroundColor = RGB(245, 245, 245, 1);
    listTV.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    listTV.showsVerticalScrollIndicator=NO;
    [self.view addSubview:listTV];
    
//    UILabel * contactText = [[UILabel alloc] initWithFrame: CGRectMake(0, kHeight-100, kWidth, 50)];
//    contactText.backgroundColor = [UIColor clearColor];
//    contactText.textColor=RGB(150, 150,150, 1);
//    contactText.textAlignment = NSTextAlignmentCenter;
//    contactText.font            = [UIFont systemFontOfSize:kTitleFont];
//    [contactText setText:@"联系我们\n songwei@gehua.cc"];
//    contactText.lineBreakMode = NSLineBreakByWordWrapping;
//    contactText.numberOfLines = 0;
//    [self.view addSubview:contactText];


}
#pragma mark ---table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"TimelineCell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellIdentifier];
        cell.backgroundColor=RGB(245, 245, 245, 1);
        [cell.contentView setBackgroundColor:RGB(245, 245, 245, 1)];
        [cell.contentView setFrame:CGRectMake(0, 0, kWidth, 50)];
        
        
        UILabel *titleLabel        = [UILabel new];
        titleLabel.tag             = 1111;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font            = [UIFont systemFontOfSize:16.f];
        titleLabel.textColor       = [UIColor blackColor];
        titleLabel.textAlignment=NSTextAlignmentLeft;
        [titleLabel setFrame:CGRectMake(25,5,150,40)];
        [[cell contentView]addSubview:titleLabel];
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    NSString *titlestring;
    UILabel *titleLabel = (UILabel *)[cell viewWithTag:1111];
    if (indexPath.row==0) {
        titlestring= @"功能介绍";
    }
    if (indexPath.row==1) {
        titlestring= @"系统设置";
    }
    [titleLabel setText:titlestring];
    
    return cell;
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:{
            HelpViewController *nextview=[[HelpViewController alloc]init];
            [self.navigationController pushViewController:nextview animated:YES];
            
        }
            
            break;
        case 1:{
            SettingDetailViewController *nextview=[[SettingDetailViewController alloc]init];
            [self.navigationController pushViewController:nextview animated:YES];
        }
            
            break;
            
        default:
            break;
    }
    
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
