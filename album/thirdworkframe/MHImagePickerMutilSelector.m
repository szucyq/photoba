//
//  MHMutilImagePickerViewController.m
//  doujiazi
//
//  Created by Shine.Yuan on 12-8-7.
//  Copyright (c) 2012年 mooho.inc. All rights reserved.
//

#import "MHImagePickerMutilSelector.h"
#import <QuartzCore/QuartzCore.h>
#import "constants.h"
#import <AssetsLibrary/ALAsset.h>

#import <AssetsLibrary/ALAssetsLibrary.h>

#import <AssetsLibrary/ALAssetsGroup.h>

#import <AssetsLibrary/ALAssetRepresentation.h>
@interface MHImagePickerMutilSelector ()

@end

@implementation MHImagePickerMutilSelector

@synthesize imagePicker;
@synthesize delegate;

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        pics=[[NSMutableArray alloc] init];
        infos=[[NSMutableArray alloc] init];

        //[pics addObject:@""];
        [self.view setBackgroundColor:[UIColor blackColor]];
        
        //if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]){
            
        //}
    }
    return self;
}

+(id)standardSelector
{
    return [[MHImagePickerMutilSelector alloc] init];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (navigationController.viewControllers.count>=2) {
        [[viewController.view.subviews objectAtIndex:0] setFrame:CGRectMake(0, 0, kWidth, kHeight-131)];
        
        selectedPan=[[UIView alloc] initWithFrame:CGRectMake(0, kHeight-131, kWidth, 131)];
        
        UIImageView* imv=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kWidth, 131)];
        [imv setBackgroundColor:[UIColor whiteColor]];
//        [imv setImage:[UIImage imageNamed:@"img_imagepicker_mutilselectbg"]];
        [selectedPan addSubview:imv];
        
        textlabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 13, 300, 14)];
        [textlabel setBackgroundColor:[UIColor clearColor]];
        [textlabel setFont:[UIFont systemFontOfSize:14.0f]];
        [textlabel setTextColor:[UIColor blackColor]];
        [textlabel setText:@"当前选中0张(最多10张)"];
        [selectedPan addSubview:textlabel];
        
        UIButton*   btn_done=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn_done setFrame:CGRectMake(kWidth-80, 5, 60, 40)];
        [btn_done setBackgroundColor:[UIColor clearColor]];
        [btn_done setTitle:@"完成" forState:UIControlStateNormal];
        [btn_done setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_done addTarget:self action:@selector(doneHandler) forControlEvents:UIControlEventTouchUpInside];
        
        [selectedPan addSubview:btn_done];
        
        
        tbv=[[UITableView alloc] initWithFrame:CGRectMake(0, 50, 90, kWidth) style:UITableViewStylePlain];
        
        tbv.transform=CGAffineTransformMakeRotation(M_PI * -90 / 180);
        tbv.center=CGPointMake(160, 131-90/2);
        [tbv setRowHeight:100];
        [tbv setShowsVerticalScrollIndicator:NO];
        [tbv setPagingEnabled:YES];
        
        tbv.dataSource=self;
        tbv.delegate=self;
        
        [tbv setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
        
        [tbv setBackgroundColor:[UIColor clearColor]];
        
        
        [tbv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [selectedPan addSubview:tbv];
        [viewController.view addSubview:selectedPan];
    }else{
        [pics removeAllObjects];
        [infos removeAllObjects];

        
    }
}

-(void)doneHandler
{
    if (delegate && [delegate respondsToSelector:@selector(imagePickerMutilSelectorDidGetImages: GetInfos:)]) {
        [delegate performSelector:@selector(imagePickerMutilSelectorDidGetImages: GetInfos:) withObject:pics withObject:infos];
    }
    [self close];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return pics.count;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger row=indexPath.row;
    if (cell==nil) {
        cell=[[UITableViewCell alloc] initWithFrame:CGRectZero];
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        
        UIView* rotateView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 80 , 80)];
        [rotateView setBackgroundColor:[UIColor blueColor]];
        rotateView.transform=CGAffineTransformMakeRotation(M_PI * 90 / 180);
        rotateView.center=CGPointMake(45, 45);
        [cell.contentView addSubview:rotateView];
        
        UIImageView* imv=[[UIImageView alloc] initWithImage:[pics objectAtIndex:row]];
        [imv setFrame:CGRectMake(0, 0, 80, 80)];
        [imv setClipsToBounds:YES];
        [imv setContentMode:UIViewContentModeScaleAspectFill];
        
        [imv.layer setBorderColor:[UIColor whiteColor].CGColor];
        [imv.layer setBorderWidth:2.0f];
        
        [rotateView addSubview:imv];
        
        UIButton*   btn_delete=[UIButton buttonWithType:UIButtonTypeCustom];
        [btn_delete setFrame:CGRectMake(0, 0, 22, 22)];
        [btn_delete setImage:[UIImage imageNamed:@"image删除"] forState:UIControlStateNormal];
        [btn_delete setCenter:CGPointMake(70, 10)];
        [btn_delete addTarget:self action:@selector(deletePicHandler:) forControlEvents:UIControlEventTouchUpInside];
        [btn_delete setTag:row];
        
        [rotateView addSubview:btn_delete];
    }
    
    return cell;
}

-(void)deletePicHandler:(UIButton*)btn
{
    [pics removeObjectAtIndex:btn.tag];
    [infos removeObjectAtIndex:btn.tag];

    [self updateTableView];
}

-(void)updateTableView
{
    textlabel.text=[NSString stringWithFormat:@"当前选中%i张(最多10张)",(int)pics.count];
    
    [tbv reloadData];
    
    if (pics.count>3) {
        CGFloat offsetY=tbv.contentSize.height-tbv.frame.size.height-(kWidth-90);
        [tbv setContentOffset:CGPointMake(0, offsetY) animated:YES];
    }else{
        [tbv setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photoimage=[[UIImage alloc]init];
    if(picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary){
        photoimage= [info objectForKey:UIImagePickerControllerOriginalImage];
        
        NSURL *assetURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:assetURL
                 resultBlock:^(ALAsset *asset) {
                     NSDictionary* imageMetadata = [[NSMutableDictionary alloc] initWithDictionary:asset.defaultRepresentation.metadata];
                     NSDictionary *GPSDict=[imageMetadata objectForKey:@"{GPS}"];
                     if (pics.count>=10) {
                         return;
                     }
                     
                     [pics addObject:photoimage];
                     [infos addObject:imageMetadata];
                 }
                failureBlock:^(NSError *error) { 
                }];
    } 

    [self updateTableView];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self close];
}

-(void)close
{
    [imagePicker dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
