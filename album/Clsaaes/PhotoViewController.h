//
//  PhotoViewController.h
//  album
//
//  Created by seven on 15/7/15.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>

@interface PhotoViewController : UIViewController<BMKGeneralDelegate,BMKGeoCodeSearchDelegate>

-(IBAction)photodetailAction;


@end
