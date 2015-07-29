//
//  MyTime.m
//  album
//
//  Created by seven on 15/7/28.
//  Copyright (c) 2015年 seven. All rights reserved.
//

#import "MyTime.h"

@implementation MyTime
+(NSString *) timenowStr{
    NSDate *date = [NSDate date];
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate: date];
    NSDate *localeDate = [date  dateByAddingTimeInterval: interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSTimeInterval time=[localeDate timeIntervalSince1970]*1000;
    long long int datess = (long long int)time;
    NSString *tablenameStr=[NSString stringWithFormat:@"%lld",datess];
    
    return tablenameStr;
}

+(NSString*)dbpathStr{
    NSString *docsDir;
    NSArray *dirPaths;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
   NSString* databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"paiba.sqlite"]];

    return databasePath;
}
@end
