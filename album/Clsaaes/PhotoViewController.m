//
//  PhotoViewController.m
//  album
//
//  Created by seven on 15/7/15.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "PhotoViewController.h"
#import "constants.h"
#import "SinglePhotoViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIButton+Badge.h"
#import "CustomAlertView.h"
#import "MyTime.h"
#import <sqlite3.h>
#import <AssetsLibrary/ALAsset.h>
#import <BaiduMapAPI/BMapKit.h>

#import <AssetsLibrary/ALAssetsLibrary.h>

#import <AssetsLibrary/ALAssetsGroup.h>

#import <AssetsLibrary/ALAssetRepresentation.h>
@class CustomAlertView;

@interface PhotoViewController ()<MHImagePickerMutilSelectorDelegate,UIImagePickerControllerDelegate, UIActionSheetDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>{

    CustomAlertView *alertView;
    NSMutableArray *imageArray;
    NSMutableArray *dataArray;

    int currentindex;
    int yearindex;
    int nowyearindex;
    NSString *databasePath;
    sqlite3 *paibaDB;

    UILabel *yearTextLabel;
    UIButton* rightyearbutton;
    NSString *addressStr;
    
    UIImage *currentimage;
    NSDictionary *currentDic;
    int currentimageindex;
    
    UIScrollView *contentSV;
    
    NSMutableArray *takephotoArray;
    NSMutableArray *takephotoindoArray;

}
@property (nonatomic, retain) UIImagePickerController *imagePickerController;

- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType;

@end

@implementation PhotoViewController
#pragma mark
#pragma mark viewload

-(void)viewWillAppear:(BOOL)animated{
    
    self.tabBarController.tabBar.hidden=NO;
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    imageArray=[[NSMutableArray alloc]init];
    takephotoArray=[[NSMutableArray alloc]init];
    takephotoindoArray=[[NSMutableArray alloc]init];
    self.view.backgroundColor=RGB(255, 255, 255, 1);
    
    UIImageView *navigationbarimg=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth,kNavHeight)];
    navigationbarimg.backgroundColor=RGB(54, 150, 207,1);
    [self.view addSubview:navigationbarimg];
    
    UILabel *titleText = [[UILabel alloc] initWithFrame: CGRectMake(0, 20, kWidth, 50)];
    titleText.backgroundColor = [UIColor clearColor];
    titleText.textColor=[UIColor whiteColor];
    titleText.textAlignment = NSTextAlignmentCenter;
    titleText.font            = [UIFont systemFontOfSize:kNavTitleFont];
    [titleText setText:@"随手拍"];
    [self.view addSubview:titleText];
    
    UIButton *photobutton=[[UIButton alloc]initWithFrame:CGRectMake(kWidth-40, 35, 25, 20)];
    [photobutton setImage:[UIImage imageNamed:@"icon-camera"]  forState:UIControlStateNormal];
    [photobutton addTarget:self action:@selector(photoAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:photobutton];
    
    yearTextLabel = [[UILabel alloc] initWithFrame: CGRectMake(0, 80, kWidth, 30)];
    yearTextLabel.backgroundColor = [UIColor clearColor];
    yearTextLabel.textColor=[UIColor blackColor];
    yearTextLabel.textAlignment = NSTextAlignmentCenter;
    yearTextLabel.font            = [UIFont systemFontOfSize:kTitleFont];
    
    NSDate * date = [NSDate date];
    NSTimeInterval sec = [date timeIntervalSinceNow];
    NSDate * currentDate = [[NSDate alloc] initWithTimeIntervalSinceNow:sec];
    NSDateFormatter * df = [[NSDateFormatter alloc] init ];
    [df setDateFormat:@"yyyy"];
    NSString * yeartext = [df stringFromDate:currentDate];
    int intString = [yeartext intValue];
    nowyearindex=intString;
    yearindex=intString;
    [yearTextLabel setText:[yeartext stringByAppendingString:@"年"]];
    [self.view addSubview:yearTextLabel];

    
    
    UIButton* leftyearbutton=[[UIButton alloc]initWithFrame:CGRectMake( kWidth/2-80, 75, 60, 40)];
    leftyearbutton.titleLabel.font=[UIFont systemFontOfSize:25];
    [leftyearbutton setTitle:@"<" forState:UIControlStateNormal];
    [leftyearbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftyearbutton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [leftyearbutton addTarget:self action:@selector(leftyearAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftyearbutton];

    
    rightyearbutton=[[UIButton alloc]initWithFrame:CGRectMake( kWidth/2+80, 75, 60, 40)];
    rightyearbutton.hidden=YES;
    rightyearbutton.titleLabel.font=[UIFont systemFontOfSize:25];
    [rightyearbutton setTitle:@">" forState:UIControlStateNormal];
    [rightyearbutton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightyearbutton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [rightyearbutton addTarget:self action:@selector(rightyearAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightyearbutton];

 
    
    [self getdata:[NSString stringWithFormat:@"%d",yearindex]];

    
}

-(void)reloadscrollerview{
    if (contentSV.superclass) {
        [contentSV removeFromSuperview];
    }
    contentSV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 120, kWidth, kHeight-170)];
    contentSV.bounces = YES;
    contentSV.pagingEnabled = NO;
    contentSV.delegate = self;
    contentSV.userInteractionEnabled = YES;
    contentSV.showsHorizontalScrollIndicator = NO;
    contentSV.backgroundColor=[UIColor clearColor];
    [self.view addSubview:contentSV];
    
    
    float  imagewidth=(kWidth-2*3)/4;
    for (int i=0; i<dataArray.count; i++) {
        NSDictionary *imagerecord=[dataArray objectAtIndex:i];
        
        NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/PhotoFile"];
        NSString *imagepathstr=[NSString stringWithFormat:@"%@/%@",DocumentsPath,[imagerecord objectForKey:@"name"] ];

        UIImage *image=[UIImage imageWithContentsOfFile:imagepathstr];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i%4*(imagewidth+2),i/4*(imagewidth+2), imagewidth, imagewidth)];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleToFill;
        [imageView setImage:image];
        [contentSV addSubview:imageView];
        
        UIButton *showButton = [UIButton buttonWithType:UIButtonTypeCustom];
        showButton.frame = CGRectMake(0, 0, imagewidth, imagewidth);
        [showButton addTarget:self action:@selector(showButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        showButton.tag = 1000+i;
        [imageView addSubview:showButton];
        showButton=nil;
        imageView=nil;

    }

    
    [contentSV setContentSize:CGSizeMake(kWidth, kHeight-170)];
    [contentSV setContentOffset:CGPointMake(0, 0)];


}
#pragma mark
#pragma mark get data from sqlite

-(void)getdata:(NSString *)yearstr{
    dataArray=[[NSMutableArray alloc]init];
    sqlite3_stmt *statement;
    
    databasePath=[MyTime dbpathStr];
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &paibaDB) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT name , detail,time , year ,month ,address ,longitude ,latitude ,type  from PHOTOS where year=\"%@\"",yearstr];
        const char *query_stmt = [querySQL UTF8String];
        if (sqlite3_prepare_v2(paibaDB, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *namestr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 0)];
                NSString *detailstr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 1)];

                NSString *timestr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 2    )];
                
                NSString *yearstr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 3    )];
                NSString *monthstr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 4    )];
                NSString *addressstr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 5    )];
                NSString *longitudestr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 6    )];
                NSString *latitudestr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 7    )];
                NSString *typestr = [[NSString alloc] initWithUTF8String:(const char *)sqlite3_column_text(statement, 8    )];

                NSDictionary *record=[[NSDictionary alloc]initWithObjectsAndKeys:namestr,@"name",detailstr,@"detail",timestr,@"time",yearstr,@"year",monthstr,@"month",addressstr,@"address",longitudestr,@"longitude",latitudestr,@"latitude",typestr,@"type", nil];
                [dataArray addObject:record];
            }
            sqlite3_finalize(statement);
        }
        
        sqlite3_close(paibaDB);
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"time" ascending:YES];
    NSArray *tempsArray = [dataArray sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    NSArray* reversedArray = [[tempsArray reverseObjectEnumerator] allObjects];
    NSLog(@"reversedArray is %@",reversedArray);

//    [allArray addObjectsFromArray:reversedArray];

    [self reloadscrollerview];
}

#pragma mark
#pragma mark button click methode

-(void)showButtonAction:(UIButton*)sender{
    
    SinglePhotoViewController
    *nextview=[[SinglePhotoViewController alloc]init];
    nextview.currentimageIndex=(int)sender.tag-1000;
    nextview.imagearray=dataArray;
    [self.navigationController pushViewController:nextview animated:YES];


}
//查看上一年照片
-(void)leftyearAction{
    yearindex--;
    if (yearindex==nowyearindex) {
        rightyearbutton.hidden=YES;
    }else{
        rightyearbutton.hidden=NO;
    }
    [yearTextLabel setText:[NSString stringWithFormat:@"%d年",yearindex]];
    
    [self getdata:[NSString stringWithFormat:@"%d",yearindex]];
}

//查看下一年照片
-(void)rightyearAction{
    
    yearindex++;
    if (yearindex==nowyearindex) {
        rightyearbutton.hidden=YES;
    }else{
        rightyearbutton.hidden=NO;
        
    }

    [yearTextLabel setText:[NSString stringWithFormat:@"%d年",yearindex]];
    
    [self getdata:[NSString stringWithFormat:@"%d",yearindex]];

    
}

//点击单张照片，查看照片详情
-(void)photodetailAction{



}

//点击拍照按钮
-(void)photoAction:(UIButton*)sender{
    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];


}

#pragma mark
#pragma mark UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://照相机
        {
            currentindex=0;
            UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
            if (![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]) {
                sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            }
            
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            self.imagePickerController = picker;
            [self setupImagePicker:sourceType];
            picker = nil;
            
            UIToolbar *cameraOverlayView = (UIToolbar *)self.imagePickerController.cameraOverlayView;
            UIBarButtonItem *doneItem = [[cameraOverlayView items] lastObject];
            [doneItem setTitle:@"取消"];
            
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        }
            break;
        case 1://本地相簿
        {
            currentindex=1;
            
            MHImagePickerMutilSelector* imagePickerMutilSelector=[MHImagePickerMutilSelector standardSelector];//自动释放
            imagePickerMutilSelector.delegate=self;//设置代理
            
            UIImagePickerController* picker=[[UIImagePickerController alloc] init];
            picker.delegate=imagePickerMutilSelector;//将UIImagePicker的代理指向到imagePickerMutilSelector
            [picker setAllowsEditing:NO];
            picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
            picker.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
            picker.navigationController.delegate=imagePickerMutilSelector;//将UIImagePicker的导航代理指向到imagePickerMutilSelector
            
            imagePickerMutilSelector.imagePicker=picker;//使imagePickerMutilSelector得知其控制的UIImagePicker实例，为释放时需要。
            
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark 自定义照片拍摄
//这里是主要函数
- (void)setupImagePicker:(UIImagePickerControllerSourceType)sourceType
{
    self.imagePickerController.sourceType = sourceType;
    
    if (sourceType == UIImagePickerControllerSourceTypeCamera)
    {
        // 不使用系统的控制界面
        self.imagePickerController.showsCameraControls = NO;
        
        UIToolbar *controlView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44)];
        controlView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        //闪光灯
        UIButton *flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        flashBtn.frame = CGRectMake(0, 0, 35, 35);
        flashBtn.showsTouchWhenHighlighted = YES;
        flashBtn.tag = 100;
        //        [flashBtn setImage:GET_IMAGE(@"camera_flash_auto.png", nil) forState:UIControlStateNormal];
        [flashBtn addTarget:self action:@selector(pushButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *flashItem = [[UIBarButtonItem alloc] initWithCustomView:flashBtn];
        
        //拍照
        UIButton *cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cameraBtn.frame = CGRectMake(0, 0, 35, 35);
        cameraBtn.showsTouchWhenHighlighted = YES;
        [cameraBtn setImage:[UIImage imageNamed:@"camera_icon.png"] forState:UIControlStateNormal];
        [cameraBtn addTarget:self action:@selector(stillImage:) forControlEvents:UIControlEventTouchUpInside];
        [cameraBtn badgeNumber:-1];
        UIBarButtonItem *takePicItem = [[UIBarButtonItem alloc] initWithCustomView:cameraBtn];
        
        //摄像头切换
        UIButton *cameraDevice = [UIButton buttonWithType:UIButtonTypeCustom];
        cameraDevice.frame = CGRectMake(0, 0, 35, 35);
        cameraDevice.showsTouchWhenHighlighted = YES;
        [cameraDevice setImage:[UIImage imageNamed:@"camera_mode.png"] forState:UIControlStateNormal];
        
        [cameraDevice addTarget:self action:@selector(changeCameraDevice:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *cameraDeviceItem = [[UIBarButtonItem alloc] initWithCustomView:cameraDevice];
        if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            //判断是否支持前置摄像头
            cameraDeviceItem.enabled = NO;
        }
        
        //取消、完成
        UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered
                                                                    target:self action:@selector(doneAction)];
        
        //模式：单张、多张
        UIButton *modeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        modeBtn.frame = CGRectMake(0, 0, 35, 35);
        modeBtn.showsTouchWhenHighlighted = YES;
        modeBtn.tag = 101;
        [modeBtn setImage:GET_IMAGE(@"camera_set.png", nil) forState:UIControlStateNormal];
        [modeBtn addTarget:self action:@selector(pushButton:) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *modeItem = [[UIBarButtonItem alloc] initWithCustomView:modeBtn];
        
        //空item
        UIBarButtonItem *spItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        NSArray *items = [NSArray arrayWithObjects:flashItem,modeItem,spItem,takePicItem,spItem,cameraDeviceItem,doneItem, nil];
        [controlView setItems:items];
        
        
        self.imagePickerController.cameraOverlayView = controlView;
        
        controlView = nil;
    }
}

//拍照
- (void)stillImage:(id)sender
{
    [self.imagePickerController takePicture];
}

//完成、取消
- (void)doneAction
{
    [self imagePickerControllerDidCancel:self.imagePickerController];
    
    
}

- (void)changeCameraDevice:(id)sender
{
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceRear) {
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
            self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        }
    }
    else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    }
}

#pragma mark
#pragma mark - UIImagePickerController回调
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (currentindex==0) {
        [imageArray addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
        
//        [imageArray addObject:info];

        
        
        
        UIBarButtonItem *flashItem = [[(UIToolbar *)self.imagePickerController.cameraOverlayView items] lastObject];
        flashItem.title = @"完成";
        UIToolbar *view = (UIToolbar *)self.imagePickerController.cameraOverlayView;
        UIBarButtonItem *cameraItem = [[view items] objectAtIndex:3];
        [(UIButton *)cameraItem.customView setBadge:(int)imageArray.count];
        
        
        
        
        
    }
    else if (currentindex==1){
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        
    }
    
}

#pragma mark
#pragma mark 自定义从照片库多选照片
-(void)imagePickerMutilSelectorDidGetImages:(NSArray*)imagesArray GetInfos:(NSArray *)infosArray
{
    NSMutableArray*  importItems=[[NSMutableArray alloc] initWithArray:imagesArray copyItems:YES];
    NSMutableArray*  infoItems=[[NSMutableArray alloc] initWithArray:infosArray copyItems:YES];
    for (int i=0; i<importItems.count; i++) {
        currentDic=[infoItems objectAtIndex:i  ];
        currentimageindex=i;
        NSData*mutimageData=UIImagePNGRepresentation([importItems objectAtIndex:i]);
        currentimage = [UIImage imageWithData:mutimageData];
        
        
        if ([currentDic objectForKey:@"{GPS}"]==nil) {
            sqlite3_stmt *statement;
            databasePath=[MyTime dbpathStr];
            const char *dbpath = [databasePath UTF8String];
            
            NSString *dateStr=[NSString stringWithFormat:@"%@",[[currentDic objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]];
            NSLog(@"date2:%@",dateStr);
            NSString *yearstr=nil;
            NSString *monthstr=nil;
            NSString *timestr=nil;
            if(dateStr){
                yearstr=[dateStr substringToIndex:4];
                
                monthstr=[dateStr substringWithRange:NSMakeRange(5, 2)];
                timestr=[MyTime timenowStr];
            }
            

            
            NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/PhotoFile"];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *imagenamestr=[NSString stringWithFormat:@"/%@%d.png",timestr,currentimageindex ];
            [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:imagenamestr] contents:mutimageData attributes:nil];
            
            if (sqlite3_open(dbpath, &paibaDB)==SQLITE_OK) {
                NSString *longitudeStr=[NSString stringWithFormat:@"%@",[[currentDic objectForKey:@"{GPS}"] objectForKey:@"Longitude"] ];
                NSString *latitudeStr=[NSString stringWithFormat:@"%@",[[currentDic objectForKey:@"{GPS}"] objectForKey:@"Latitude"] ];
                NSString *nameStr=[NSString stringWithFormat:@"%@%d.png",timestr,currentimageindex ];
                
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PHOTOS (name,time,year,month,address,longitude,latitude,type,detail) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",nameStr,dateStr,yearstr,monthstr,addressStr,longitudeStr,latitudeStr,@"photo",@""];
                const char *insert_stmt = [insertSQL UTF8String];
                sqlite3_prepare_v2(paibaDB, insert_stmt, -1, &statement, NULL);
                if (sqlite3_step(statement)==SQLITE_DONE) {
                    NSLog(@"添加成功");
                    
                }
                else
                {
                    NSLog(@"添加失败");
                    
                }
            }
            
            sqlite3_finalize(statement);
            sqlite3_close(paibaDB);
            [self getdata:[NSString stringWithFormat:@"%d",yearindex]];

            
        }else{
            BMKGeoCodeSearch *_geoCodeSearch = [[BMKGeoCodeSearch alloc]init];
            _geoCodeSearch.delegate = self;
            BMKReverseGeoCodeOption *reverseGeoCodeOption= [[BMKReverseGeoCodeOption alloc] init];
            CLLocationCoordinate2D coor ;
            coor.latitude=[[[currentDic objectForKey:@"{GPS}"] objectForKey:@"Latitude"] floatValue];
            coor.longitude=[[[currentDic objectForKey:@"{GPS}"] objectForKey:@"Longitude"] floatValue];
            reverseGeoCodeOption.reverseGeoPoint = coor;
            [_geoCodeSearch reverseGeoCode:reverseGeoCodeOption];
        
        }
        
    }
}
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    //BMKReverseGeoCodeResult是编码的结果，包括地理位置，道路名称，uid，城市名等信息
    addressStr=result.address;
    NSString *dateStr=[NSString stringWithFormat:@"%@",[[currentDic objectForKey:@"{Exif}"] objectForKey:@"DateTimeOriginal"]];
    NSLog(@"date:%@",dateStr);
    NSString *yearstr=nil;
    NSString *monthstr=nil;
    if(dateStr){
        yearstr=[dateStr substringToIndex:4];
        monthstr=[dateStr substringWithRange:NSMakeRange(5, 2)];
    }
    
    
    CGSize size = CGSizeMake([[currentDic objectForKey:@"PixelWidth"] floatValue], [[currentDic objectForKey:@"PixelHeight"] floatValue]); //设置上下文（画布）大小
    UIGraphicsBeginImageContext(size); //创建一个基于位图的上下文(context)，并将其设置为当前上下文
    CGContextRef contextRef = UIGraphicsGetCurrentContext(); //获取当前上下文
    NSString *title =[NSString stringWithFormat:@"%@\n%@",addressStr,dateStr];  //需要添加的水印文字
    
    CGContextTranslateCTM(contextRef, 0, size.height);  //画布的高度
    CGContextScaleCTM(contextRef, 1.0, -1.0);  //画布翻转
    CGContextDrawImage(contextRef, CGRectMake(0, 0, size.width, size.height), [currentimage CGImage]);  //在上下文种画当前图片
    
    [[UIColor redColor] set];  //上下文种的文字属性
    CGContextTranslateCTM(contextRef, 0, size.height);
    CGContextScaleCTM(contextRef, 1.0, -1.0);
    
    float multipleFloat=size.width/kWidth;
    
    UIFont *font = [UIFont boldSystemFontOfSize:16*multipleFloat];
    [title drawInRect:CGRectMake(size.width-200*multipleFloat, size.height-100*multipleFloat, 200*multipleFloat, 80*multipleFloat) withFont:font];
    UIImage *res =UIGraphicsGetImageFromCurrentImageContext();  //从当前上下文种获取图片
    UIGraphicsEndImageContext(); //移除栈顶的基于当前位图的图形上下文。
    NSString *timestr=[MyTime timenowStr];
    
    sqlite3_stmt *statement;
    databasePath=[MyTime dbpathStr];
    const char *dbpath = [databasePath UTF8String];
    
    
    NSData *imageData = UIImagePNGRepresentation(res);
    
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/PhotoFile"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *imagenamestr=[NSString stringWithFormat:@"/%@%d.png",timestr,currentimageindex ];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:imagenamestr] contents:imageData attributes:nil];
    
    if (sqlite3_open(dbpath, &paibaDB)==SQLITE_OK) {
        NSString *longitudeStr=[NSString stringWithFormat:@"%@",[[currentDic objectForKey:@"{GPS}"] objectForKey:@"Longitude"] ];
        NSString *latitudeStr=[NSString stringWithFormat:@"%@",[[currentDic objectForKey:@"{GPS}"] objectForKey:@"Latitude"] ];
        NSString *nameStr=[NSString stringWithFormat:@"%@%d.png",timestr,currentimageindex ];

                    NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO PHOTOS (name,time,year,month,address,longitude,latitude,type,detail) VALUES(\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\",\"%@\")",nameStr,dateStr,yearstr,monthstr,addressStr,longitudeStr,latitudeStr,@"photo",@""];
                    const char *insert_stmt = [insertSQL UTF8String];
                    sqlite3_prepare_v2(paibaDB, insert_stmt, -1, &statement, NULL);
                    if (sqlite3_step(statement)==SQLITE_DONE) {
                        NSLog(@"添加成功");
        
                    }
                    else
                    {
                        NSLog(@"添加失败");

                    }
    }
    
    sqlite3_finalize(statement);
    sqlite3_close(paibaDB);

    [self getdata:[NSString stringWithFormat:@"%d",yearindex]];

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
