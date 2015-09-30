//
//  AddThemeViewController.m
//  album
//
//  Created by seven on 15/7/16.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "AddThemeViewController.h"
#import "constants.h"
#import <sqlite3.h>
#import "MyTime.h"
#import <AssetsLibrary/ALAsset.h>

#import <AssetsLibrary/ALAssetsLibrary.h>

#import <AssetsLibrary/ALAssetsGroup.h>

#import <AssetsLibrary/ALAssetRepresentation.h>

@interface AddThemeViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate>{

    UITextField *nameTF;
    UITextField *detailTF;
    NSString *databasePath;
    sqlite3 *paibaDB;
    MyTime  *myTime;
    NSString *imagenamestr;
    UIImageView *posterimageview;

}

@end

@implementation AddThemeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"the dic is %@",self.editDic);
    imagenamestr=@"";
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
    if (self.isEdit ==YES) {
        [titleText setText:@"编辑主题"];
    }else{
        [titleText setText:@"添加新主题"];
    }

    [self.view addSubview:titleText];
    
    UIButton* backbutton=[[UIButton alloc]initWithFrame:CGRectMake(10, 20, 60, 40)];
    backbutton.titleLabel.font=[UIFont systemFontOfSize:16];
    [backbutton setImage:[UIImage imageNamed:@"back-white"] forState:UIControlStateNormal];
    [backbutton setTitle:@"   返回" forState:UIControlStateNormal];
    [backbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [backbutton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [backbutton addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backbutton];
    
    UIButton* saveAction = [[UIButton alloc]initWithFrame:CGRectMake(kWidth-70, 30,60,30)];
    [saveAction setBackgroundColor:[UIColor clearColor]];
    [saveAction setTitle:@" 保存 " forState:UIControlStateNormal];
    [saveAction setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [saveAction setTitleColor:RGB(255, 255, 255, 1) forState:UIControlStateHighlighted];
    [saveAction addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveAction];

    

    UILabel* nameText = [[UILabel alloc] initWithFrame: CGRectMake(0, 90, 80, 50)];
    nameText.backgroundColor = [UIColor clearColor];
    nameText.textColor=RGB(67,67,67,1);
    nameText.textAlignment = NSTextAlignmentCenter;
    nameText.font            = [UIFont systemFontOfSize:16.0];
    [nameText setText:@"名称"];
    [self.view addSubview:nameText];
    
    nameTF=[[UITextField alloc]initWithFrame:CGRectMake(80, 90, kWidth-90, 45)];
    nameTF.delegate=self;
    nameTF.placeholder=@"  填写主题名称";
    [nameTF setBackgroundColor:[UIColor whiteColor]];
    nameTF.layer.borderColor = RGB(238, 238, 238, 1).CGColor;
    nameTF.layer.borderWidth = 1.0f;
    nameTF.returnKeyType=UIReturnKeyNext;
    [self.view addSubview:nameTF];
    
    UILabel* detailText = [[UILabel alloc] initWithFrame: CGRectMake(0, 160, 80, 50)];
    detailText.backgroundColor = [UIColor clearColor];
    detailText.textColor=RGB(67,67,67,1);
    detailText.textAlignment = NSTextAlignmentCenter;
    detailText.font            = [UIFont systemFontOfSize:16.0];
    [detailText setText:@"描述"];
    [self.view addSubview:detailText];
    
    detailTF=[[UITextField alloc]initWithFrame:CGRectMake(80, 160, kWidth-90, 45)];
    detailTF.delegate=self;
    detailTF.placeholder=@"  填写主题描述";
    [detailTF setBackgroundColor:[UIColor whiteColor]];
    detailTF.layer.borderColor = RGB(238, 238, 238, 1).CGColor;
    detailTF.layer.borderWidth = 1.0f;
    detailTF.returnKeyType=UIReturnKeyNext;
    [self.view addSubview:detailTF];
    
    UILabel* posterText = [[UILabel alloc] initWithFrame: CGRectMake(0, 230, 80, 50)];
    posterText.backgroundColor = [UIColor clearColor];
    posterText.textColor=RGB(67,67,67,1);
    posterText.textAlignment = NSTextAlignmentCenter;
    posterText.font            = [UIFont systemFontOfSize:16.0];
    [posterText setText:@"封面"];
    [self.view addSubview:posterText];

    posterimageview=[[UIImageView alloc]initWithFrame:CGRectMake(80, 230, kWidth-90, (kWidth-90)*3/4)];
    [posterimageview setImage:[UIImage imageNamed:@"默认"]];
    posterimageview.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:posterimageview];

    UIButton *posterimageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    posterimageButton.backgroundColor=[UIColor clearColor];
    posterimageButton.frame = CGRectMake(80, 300, kWidth-90, (kWidth-90)*3/4);
    [posterimageButton addTarget:self action:@selector(editimageAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:posterimageButton];

}
#pragma mark
#pragma mark action
-(void)editimageAction{

    UIActionSheet *choiceSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"取消"
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:@"拍照", @"从相册中选取", nil];
    [choiceSheet showInView:self.view];

}

#pragma mark -
#pragma UIActionSheet Delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0://照相机
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        case 1://本地相簿
        {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [self.navigationController presentViewController:imagePicker animated:YES completion:nil];
        }
            break;
        default:
            break;
    }
}

-(void)backAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveAction:(UIButton*)sender{
    
    if (self.isEdit==YES) {
        if (nameTF.text.length==0) {

        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"主题名称不能为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        [alertView show];
        return;
        
    }
    else if (detailTF.text.length==0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"主题描述不能为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        [alertView show];
        return;
        
        
    }
    else{
        
        NSLog(@"imagestr is %@",imagenamestr);
        sqlite3_stmt *statement;
        
        databasePath=[MyTime dbpathStr];
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &paibaDB)==SQLITE_OK) {
            NSString *editSQL = [NSString stringWithFormat:@"update testTable set name = %@ and detail = %@ WHERE themeID = %@",nameTF.text,detailTF.text,imagenamestr];

//            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO THEMES (themeID,name,detail,postername) VALUES(\"%@\",\"%@\",\"%@\")",nameTF.text,detailTF.text,imagenamestr];
            
            char *sql = "update testTable set testValue = ? and testName = ? WHERE testID = ?";

            
            const char *insert_stmt = [editSQL UTF8String];
            sqlite3_prepare_v2(paibaDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement)==SQLITE_DONE) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadthemelist"object:nil];
                NSLog(@"添加成功");
                
                [self backAction];
            }
            else
            {
                
                NSLog(@"添加失败");
            }
            sqlite3_finalize(statement);
            sqlite3_close(paibaDB);
        }

        
        
        
    }
        
    }
    else{
        
    if (nameTF.text.length==0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"主题名称不能为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        [alertView show];
        return;

    }
    else if (detailTF.text.length==0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"主题描述不能为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        [alertView show];
        return;

    
    }
    else{
        NSLog(@"imagestr is %@",imagenamestr);
        sqlite3_stmt *statement;

        databasePath=[MyTime dbpathStr];
        NSString *themeidstr=[MyTime timenowStr];
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &paibaDB)==SQLITE_OK) {
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO THEMES (themeID,name,detail,postername) VALUES(\"%@\",\"%@\",\"%@\",\"%@\")",themeidstr,nameTF.text,detailTF.text,imagenamestr];
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(paibaDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement)==SQLITE_DONE) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadthemelist"object:nil];
                NSLog(@"添加成功");

                [self backAction];
            }
            else
            {
                
                NSLog(@"添加失败");
            }
            sqlite3_finalize(statement);
            sqlite3_close(paibaDB);
        }

    
    
    }

    }
}

#pragma mark
#pragma mark UITextField delegate methode

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    if (textField==nameTF) {
        [nameTF resignFirstResponder];
    }
    if (textField==detailTF) {
        [detailTF resignFirstResponder];
    }

    return YES;
}

#pragma mark -
#pragma UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    [posterimageview setImage:[UIImage imageNamed:@"默认"]];
    NSData*mutimageData = UIImageJPEGRepresentation([info objectForKey:@"UIImagePickerControllerEditedImage"], 0.3);

    
    UIImage* image=[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageOrientation imageOrientation=image.imageOrientation;
    if(imageOrientation!=UIImageOrientationUp)
    {
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        posterimageview.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
            // 调整图片角度完毕
    }
    
    NSString *timestr=[MyTime timenowStr];
    NSString * DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    imagenamestr=[NSString stringWithFormat:@"/%@.png",timestr ];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:imagenamestr] contents:mutimageData attributes:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
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
