//
//  SinglePhotoViewController.m
//  album
//
//  Created by seven on 15/7/16.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "SinglePhotoViewController.h"
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

@interface SinglePhotoViewController ()<UIScrollViewDelegate,UITextViewDelegate>{

    UIScrollView    *contentSV;
    int             scrollerIndex;
    UITextView      *infoTextView;
}

@end

@implementation SinglePhotoViewController
@synthesize currentimageIndex,imagearray;

-(void)viewDidAppear:(BOOL)animated{

    for (int i=0; i < [imagearray count]; i++) {
        NSDictionary *imagerecord=[imagearray objectAtIndex:i];
        
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/PhotoFile"];
        NSString *imagepathstr=[NSString stringWithFormat:@"%@/%@",DocumentsPath,[imagerecord objectForKey:@"name"] ];
        UIImage *image=[UIImage imageWithContentsOfFile:imagepathstr];
        
        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(kWidth * i, 0, kWidth, kHeight)];
        [iv setImage:image];
        iv.contentMode=UIViewContentModeScaleAspectFit;
        [contentSV addSubview:iv];
        iv = nil;
    }

}
- (void)viewDidLoad {
    scrollerIndex=currentimageIndex;
    NSLog(@"imagedata is %@",imagearray);
    NSLog(@"currentindex is %d",currentimageIndex);
    [super viewDidLoad];
    self.view.backgroundColor=RGB(255, 255, 255, 1);
    self.tabBarController.tabBar.hidden=YES;

    contentSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
    contentSV.backgroundColor=[UIColor whiteColor];
//    contentSV.bounces = YES;
    contentSV.pagingEnabled = YES;
    contentSV.delegate = self;
//    contentSV.userInteractionEnabled = YES;
    contentSV.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:contentSV];
    
    [contentSV setContentSize:CGSizeMake(kWidth*imagearray.count, 0)];
    [contentSV setContentOffset:CGPointMake(0, 0)];
    

    
    
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
    
//    UIButton *photobutton=[[UIButton alloc]initWithFrame:CGRectMake(20, 30, 29, 29)];
//    [photobutton setImage:[UIImage imageNamed:@"icon-camera"]  forState:UIControlStateNormal];
//    [photobutton addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:photobutton];
    
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
    
    infoTextView=[[UITextView alloc]initWithFrame:CGRectMake(0, kHeight-100, kWidth, 100)];
    infoTextView.delegate=self;
    [infoTextView setBackgroundColor:RGB(67, 67, 67, 0.9)];
    infoTextView.returnKeyType=UIReturnKeyDone;
    
    [self.view addSubview:infoTextView];

    

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
#pragma mark
#pragma mark-- UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidScroll");
    if (scrollView == contentSV) {
        CGFloat pageWidth = scrollView.frame.size.width;
        int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        scrollerIndex = page;
    }
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    //NSLog(@"scrollViewDidEndDecelerating");
    if (scrollView == contentSV) {

    }else {
        
    }
}
#pragma mark
#pragma mark-----UITextField delegate
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView ==infoTextView) {
        if ([text isEqualToString:@"\n"]) {
            [infoTextView resignFirstResponder];
            infoTextView.frame=CGRectMake(0, kHeight-100, kWidth, 100);
            return NO;
        }
    }
    return YES;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{

    NSLog(@"begin editing");
    
    infoTextView.frame=CGRectMake(0, kHeight-350, kWidth, 100);

    return YES;
}

//计算自动高度
- (CGSize)labelAutoCalculateRectWith:(NSString*)text FontSize:(CGFloat)fontSize MaxSize:(CGSize)maxSize
{
    
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    
    paragraphStyle.lineBreakMode=NSLineBreakByWordWrapping;
    NSDictionary* attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize labelSize = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    
    labelSize.height=ceil(labelSize.height);
    
    labelSize.width=ceil(labelSize.width);
    
    return labelSize;
    
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
