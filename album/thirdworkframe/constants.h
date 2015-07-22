//
//  constants.h
//  gehuasing
//
//  Created by 歌华 有线数字 on 14-8-4.
//  Copyright (c) 2014年 北京歌华有线数字媒体有限公司. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MHImagePickerMutilSelector.h"
#define GET_IMAGE(__NAME__,__TYPE__)    [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:__NAME__ ofType:__TYPE__]]

#define DICT(...) [NSDictionary dictionaryWithObjectsAndKeys:__VA_ARGS__, nil]
#define RGB(r, g, b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a/1.0]
#define kWidth  [[UIScreen mainScreen] bounds].size.width
#define kHeight [[UIScreen mainScreen] bounds].size.height


#define navbar_Color                           RGB(54, 150, 207, 1)
#define kNavHeight                             70
#define kNavTitleFont                             20.0
#define kTitleFont                             18.0
#define kContentFont                             16.0
