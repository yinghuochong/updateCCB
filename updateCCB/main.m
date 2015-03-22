//
//  main.m
//  updateCCB
//
//  Created by liulihua on 15/3/22.
//  Copyright (c) 2015年 firefly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CCBCheck.h"



void writePlist(NSString *plistPath ,NSDictionary *plistDictionary){
    [plistDictionary writeToFile:plistPath atomically:YES];
}

BOOL addKeyValueToDic(NSMutableDictionary *fileMap ,NSString *key ,NSString *value){
//    if (!fileMap) return NO;
//    if(fileMap.allKeys.containsObject(key)) return NO;
//    [fileMap setObject:value forKey:key];
    return YES;
}

int main(int argc, const char * argv[]) {
    if (argc < 3)
    {
        printf("USAGE: updateCCB [resources dir] [ccb path or ccb dir]\n");
        return 0;
    }
    @autoreleasepool {
        NSString *resourceDir = [NSString stringWithUTF8String: argv[1]];
        NSString *ccbPath = [NSString stringWithUTF8String: argv[2]];
        CCBCheck *check = [[CCBCheck alloc] init];
        
        NSInteger errorCode = 0;
        // -- step 1
        /*
         1、将A中所有的图片存到字典里 【图片名字：图片路径】
         过程中如果有重复的图片，报错退出
         */
        
        NSMutableDictionary *fileMap = [check getFilePathMapWithDir:resourceDir error:&errorCode];
        if(errorCode != 0){
            NSLog(@"Error Code:%ldd",(long)errorCode);
            return -1;
        }
//        NSLog(@"fileMap : %@",fileMap);
        
        
        // -- step 2
        /*
         2、依次遍历B中的单个ccb文件
         若目录全部正确，直接通过
         若目录错误，从A找到正确的路径替换
         */
        NSLog(@"setp 2");
        NSString *pathExtension = [ccbPath pathExtension];
        BOOL isOK = YES;
        if([pathExtension isEqualToString:@"ccb"]){
            isOK = [check updateCCB:ccbPath withResource:fileMap];
        }else{
            isOK = [check updateCCBDir:ccbPath withResource:fileMap];
        }
        if(!isOK){
            NSLog(@"please check the error!!!");
            return -1;
        }
        NSLog(@"finish...!");
    }
    return 0;
}
