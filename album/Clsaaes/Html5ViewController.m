//
//  Html5ViewController.m
//  album
//
//  Created by seven on 15/7/16.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "Html5ViewController.h"
#import "constants.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboApi.h"
#import "WeiboSDK.h"
#import <RennSDK/RennSDK.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>


@interface Html5ViewController ()
@property (nonatomic,retain)NSMutableArray *picArr;
@property (nonatomic, retain)  UIWebView *contentWebView;
@end

@implementation Html5ViewController

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
    [titleText setText:@""];
    [self.view addSubview:titleText];
    
    
    
    
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
    
    self.picArr=[NSMutableArray array];
    //web view
    self.contentWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    //    self.contentWebView.delegate=self;
    [self.view addSubview:self.contentWebView];
    //images
    for (int i=0; i<3; i++) {
        Photo *photo=[[Photo alloc]init];
        photo.name=[NSString stringWithFormat:@"%@%d",@"这个是图片:",i];
        photo.imagePath=[[NSBundle mainBundle]pathForResource:[NSString stringWithFormat:@"%@%d",@"guide_",i] ofType:@"png"];
        photo.description=[NSString stringWithFormat:@"%@%d",@"这个是备注:",i];
        [self.picArr addObject:photo];
    }
    //生成html
    [self generateHtmlWith:self.picArr];
}
-(void)backAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)shareAction:(UIButton*)sender{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"ShareSDK" ofType:@"png"];
    
    //构造分享内容
    id<ISSContent> publishContent = [ShareSDK content:@"分享内容"
                                       defaultContent:@"测试一下"
                                                image:[ShareSDK imageWithPath:imagePath]
                                                title:@"ShareSDK"
                                                  url:@"http://www.mob.com"
                                          description:@"这是一条测试信息"
                                            mediaType:SSPublishContentMediaTypeNews];
    //创建弹出菜单容器
    id<ISSContainer> container = [ShareSDK container];
    [container setIPadContainerWithView:sender arrowDirect:UIPopoverArrowDirectionUp];
    
    //弹出分享菜单
    [ShareSDK showShareActionSheet:container
                         shareList:nil
                           content:publishContent
                     statusBarTips:YES
                       authOptions:nil
                      shareOptions:nil
                            result:^(ShareType type, SSResponseState state, id<ISSPlatformShareInfo> statusInfo, id<ICMErrorInfo> error, BOOL end) {
                                
                                if (state == SSResponseStateSuccess)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_SUC", @"分享成功"));
                                }
                                else if (state == SSResponseStateFail)
                                {
                                    NSLog(NSLocalizedString(@"TEXT_ShARE_FAI", @"分享失败,错误码:%d,错误描述:%@"), [error errorCode], [error errorDescription]);
                                }
                            }];
    
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
- (void)generateHtmlWith:(NSMutableArray*)sender{
    NSLog(@"pic arr:%@",sender);
    //css
    NSString *cssPath=[[NSBundle mainBundle]pathForResource:@"share" ofType:@"css"];
    NSString *cssContent=[NSString stringWithContentsOfURL:[NSURL fileURLWithPath:cssPath] encoding:NSUTF8StringEncoding error:nil];
    //titile
    NSString *title=@"我2015年深圳游玩东东";
    //source
    NSString *source=@"深圳";
    
    //image
    NSString *htmlFileBegin=[NSString stringWithFormat:@"<html><head></head><style>%@</style><body><h3>%@</h3><h4><span class=\"source\">%@</span></h4>",cssContent,title,source];
    NSString *htmlContent=[NSString string];
    for(int i=0;i<sender.count;i++){
        Photo *photo=[sender objectAtIndex:i];
        NSString *desc=photo.description;
        NSString *imagePath=photo.imagePath;
        NSLog(@"desc:%@-path:%@",desc,imagePath);
        htmlContent=[htmlContent stringByAppendingString:[NSString stringWithFormat:@"<img src=\"%@\"/><p>%@</p>",imagePath,desc]];
        NSLog(@"html content:%@",htmlContent);
    }
    NSString *htmlFileEnd=[NSString stringWithFormat:@"%@",@"</body></html>"];
    NSString *html=[NSString stringWithFormat:@"%@%@%@",htmlFileBegin,htmlContent,htmlFileEnd];
    
    NSLog(@"html:%@",html);
    [self.contentWebView loadHTMLString:html baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath]]];
}
@end
