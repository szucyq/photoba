//
//  SinglePhotoViewController.h
//  album
//
//  Created by seven on 15/7/16.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SinglePhotoViewController : UIViewController{

    NSMutableArray *imagearray;
    int currentimageIndex;

}
@property(nonatomic,assign)int currentimageIndex;
@property (nonatomic,strong)NSMutableArray *imagearray;
@end
