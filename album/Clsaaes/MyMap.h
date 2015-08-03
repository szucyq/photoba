//
//  MyMap.h
//  album
//
//  Created by seven on 15/8/4.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI/BMapKit.h>

@interface MyMap : NSObject<BMKGeoCodeSearchDelegate>
+(NSString *) addressStr;

@end
