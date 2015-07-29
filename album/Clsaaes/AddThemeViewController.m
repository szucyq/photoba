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
@interface AddThemeViewController ()<UITextFieldDelegate>{

    UITextField *nameTF;
    UITextField *detailTF;
    NSString *databasePath;
    sqlite3 *paibaDB;
    MyTime  *myTime;

}

@end

@implementation AddThemeViewController

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
    [titleText setText:@"添加新主题"];
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
    [saveAction setTitleColor:RGB(255,100,61,1) forState:UIControlStateNormal];
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


}
#pragma mark
#pragma mark action

-(void)backAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)saveAction:(UIButton*)sender{
    if (nameTF.text.length==0) {
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"主题名称不能为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        [alertView show];
        return;

    }
    else if (detailTF.text.length==0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"主题描述不能为空" message:nil delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil,nil];
        [alertView show];
        return;

    
    }else{
        
        sqlite3_stmt *statement;

        NSString * tablenameStr=[@"A" stringByAppendingString:[MyTime timenowStr]];
        databasePath=[MyTime dbpathStr];
        const char *dbpath = [databasePath UTF8String];
        
        if (sqlite3_open(dbpath, &paibaDB)==SQLITE_OK) {
            NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO THEMES (name,detail,tablename) VALUES(\"%@\",\"%@\",\"%@\")",nameTF.text,detailTF.text,tablenameStr];
            NSLog(@"insertSQL is %@",insertSQL);
            const char *insert_stmt = [insertSQL UTF8String];
            sqlite3_prepare_v2(paibaDB, insert_stmt, -1, &statement, NULL);
            if (sqlite3_step(statement)==SQLITE_DONE) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadthemelist"object:nil];
                
                NSString *creattablesql=[NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ ( name TEXT, time TEXT, address TEXT,longitude TEXT,latitude TEXT,type TEXT)",tablenameStr];
                NSLog(@"creattablesql%@",creattablesql);
                char *err;
                if (sqlite3_exec(paibaDB, [creattablesql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
                    sqlite3_close(paibaDB);
                    NSLog(@"数据库操作数据失败!");
                }

                [self backAction];
            }
            else
            {
            }
            sqlite3_finalize(statement);
            sqlite3_close(paibaDB);
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
