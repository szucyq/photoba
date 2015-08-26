//
//  AppDelegate.m
//  album
//
//  Created by seven on 15/7/15.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "AppDelegate.h"
#import "PhotoViewController.h"
#import "ThemeViewController.h"
#import "JourneyViewController.h"
#import "SettingViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import "WeiboApi.h"
#import "WeiboSDK.h"
#import <RennSDK/RennSDK.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import <sqlite3.h>
#import "constants.h"
BMKMapManager* _mapManager;

@interface AppDelegate (){

    NSString *databasePath;
    sqlite3 *paibaDB;

}

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
      handleOpenURL:(NSURL *)url
{
    return [ShareSDK handleOpenURL:url
                        wxDelegate:self];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [ShareSDK handleOpenURL:url
                 sourceApplication:sourceApplication
                        annotation:annotation
                        wxDelegate:self];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    _mapManager = [[BMKMapManager alloc]init];
    BOOL ret = [_mapManager start:@"Gscyn4f5xznBQGaZF284n902" generalDelegate:self];
    
    if (!ret) {
        NSLog(@"manager start failed!");
    }

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];
    _tabBarController = [[UITabBarController alloc]init];
    [self.window setRootViewController:_tabBarController];
    
    UINavigationController *first;
    PhotoViewController* firstview = [[PhotoViewController alloc]init];
    first = [[UINavigationController alloc] initWithRootViewController:firstview];
    first.navigationBarHidden=YES;
    
    UINavigationController *second;
    ThemeViewController* secondview = [[ThemeViewController alloc]init];
    second = [[UINavigationController alloc] initWithRootViewController:secondview];
    second.navigationBarHidden=YES;
    
    UINavigationController *third;
    JourneyViewController* thirdview = [[JourneyViewController alloc]init];
    third = [[UINavigationController alloc] initWithRootViewController:thirdview];
    third.navigationBarHidden=YES;
    
    UINavigationController *forth;
    SettingViewController* forthview = [[SettingViewController alloc]init];
    forth = [[UINavigationController alloc] initWithRootViewController:forthview];
    forth.navigationBarHidden=YES;

    _tabBarController.viewControllers = [NSArray arrayWithObjects:first, second,third ,forth,nil];
    
    UITabBar *tabBar = _tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    tabBarItem1.title = @"随手拍";
    tabBarItem2.title = @"主题拍";
    tabBarItem3.title = @"旅行拍";
    tabBarItem4.title = @"设置";
    
    [tabBarItem1 setImage:[UIImage imageNamed:@"icon-camera"]];
    [tabBarItem1 setSelectedImage:[UIImage imageNamed:@"icon-camera.png"]];
    
    [tabBarItem2 setImage:[UIImage imageNamed:@"icon-camera.png"]];
    [tabBarItem2 setSelectedImage:[UIImage imageNamed:@"icon-camera.png"]];
    
    [tabBarItem3 setImage:[UIImage imageNamed:@"icon-maps.png"]];
    [tabBarItem3 setSelectedImage:[UIImage imageNamed:@"icon-maps.png"]];
    
    [tabBarItem4 setImage:[UIImage imageNamed:@"icon-settings.png"]];
    [tabBarItem4 setSelectedImage:[UIImage imageNamed:@"icon-settings.png"]];
    
    //添加数据库，新建三个表
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documents = [paths objectAtIndex:0];
    NSString *database_path = [documents stringByAppendingPathComponent:DBNAME];
    if (sqlite3_open([database_path UTF8String], &paibaDB) != SQLITE_OK) {
        sqlite3_close(paibaDB);
        NSLog(@"数据库打开失败");
    }
    NSString *sqlCreateTable1 = @"CREATE TABLE IF NOT EXISTS PHOTOS ( name TEXT, detail TEXT,time TEXT, year TEXT,month TEXT,address TEXT,longitude TEXT,latitude TEXT,type TEXT)";
    NSString *sqlCreateTable2 = @"CREATE TABLE IF NOT EXISTS THEMES ( name TEXT, detail TEXT, postername TEXT)";
    NSString *sqlCreateTable3 = @"CREATE TABLE IF NOT EXISTS JOURNEYS (name TEXT, detail TEXT, postername TEXT)";
    
    NSString *sqlCreateTable4 = @"CREATE TABLE IF NOT EXISTS THEMEPHOTOS ( name TEXT, detail TEXT,time TEXT, year TEXT,month TEXT,address TEXT,longitude TEXT,latitude TEXT,type TEXT)";

    NSString *sqlCreateTable5 = @"CREATE TABLE IF NOT EXISTS JOURNEYPHOTOS ( name TEXT,detail TEXT, time TEXT, year TEXT,month TEXT,address TEXT,longitude TEXT,latitude TEXT,type TEXT)";

    [self execSql:sqlCreateTable1];
    [self execSql:sqlCreateTable2];
    [self execSql:sqlCreateTable3];
    [self execSql:sqlCreateTable4];
    [self execSql:sqlCreateTable5];

   //在document文件夹中添加随手拍、主题、行程文件夹
    NSString * photoDir = [documents stringByAppendingPathComponent:@"/PhotoFile"];
    [[NSFileManager defaultManager] createDirectoryAtPath:photoDir withIntermediateDirectories:YES attributes:nil error:nil];

    
    NSString * themeDir = [documents stringByAppendingPathComponent:@"/ThemeFile"];
    [[NSFileManager defaultManager] createDirectoryAtPath:themeDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    NSString * journeyDir = [documents stringByAppendingPathComponent:@"/JourneyFile"];
    [[NSFileManager defaultManager] createDirectoryAtPath:journeyDir withIntermediateDirectories:YES attributes:nil error:nil];
    
    //初始化分享sdk
    [ShareSDK connectSinaWeiboWithAppKey:@"568898243"
                               appSecret:@"38a4f8204cc784f81f9f0daaf31e02e3"
                             redirectUri:@"http://www.sharesdk.cn"];
    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
                                redirectUri:@"http://www.sharesdk.cn"
                                   wbApiCls:[WeiboApi class]];
    [ShareSDK connectQZoneWithAppKey:@"100371282"
                           appSecret:@"aed9b0303e3ed1e27bae87c33761161d"
                   qqApiInterfaceCls:[QQApiInterface class]
                     tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectQQWithQZoneAppKey:@"100371282"
                     qqApiInterfaceCls:[QQApiInterface class]
                       tencentOAuthCls:[TencentOAuth class]];
    [ShareSDK connectWeChatWithAppId:@"wx4868b35061f87885"
                           appSecret:@"64020361b8ec4c99936c0e3999a9f249"
                           wechatCls:[WXApi class]];
    [ShareSDK connectRenRenWithAppId:@"226427"
                              appKey:@"fc5b8aed373c4c27a05b712acba0f8c3"
                           appSecret:@"f29df781abdd4f49beca5a2194676ca4"
                   renrenClientClass:[RennClient class]];
    [ShareSDK connectFacebookWithAppKey:@"107704292745179"
                              appSecret:@"38053202e1a5fe26c80c753071f0b573"];
    [ShareSDK connectTwitterWithConsumerKey:@"mnTGqtXk0TYMXYTN7qUxg"
                             consumerSecret:@"ROkFqr8c3m1HXqS3rm3TJ0WkAJuwBOSaWhPbZ9Ojuc"
                                redirectUri:@"http://www.sharesdk.cn"];
    
    [ShareSDK connectGooglePlusWithClientId:@"232554794995.apps.googleusercontent.com"
                               clientSecret:@"PEdFgtrMw97aCvf0joQj7EMk"
                                redirectUri:@"http://localhost"
                                  signInCls:[GPPSignIn class]
                                   shareCls:[GPPShare class]];
    [ShareSDK importGooglePlusClass:[GPPSignIn class]
                         shareClass:[GPPShare class]];
    [ShareSDK connectSMS];
    [ShareSDK connectMail];
    [ShareSDK connectAirPrint];
    [ShareSDK connectCopy];
    return YES;
}
-(void)execSql:(NSString *)sql
{
    char *err;
    if (sqlite3_exec(paibaDB, [sql UTF8String], NULL, NULL, &err) != SQLITE_OK) {
        sqlite3_close(paibaDB);
        NSLog(@"数据库操作数据失败!");
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [BMKMapView willBackGround];

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [BMKMapView didForeGround];

}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
- (void)onGetNetworkState:(int)iError
{
    if (0 == iError) {
        NSLog(@"联网成功");
    }
    else{
        NSLog(@"onGetNetworkState %d",iError);
    }
    
}

- (void)onGetPermissionState:(int)iError
{
    if (0 == iError) {
        NSLog(@"授权成功");
    }
    else {
        NSLog(@"onGetPermissionState %d",iError);
    }
}

@end
