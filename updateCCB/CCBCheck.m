//
//  CCBCheck.m
//  updateCCB
//
//  Created by liulihua on 15/3/22.
//  Copyright (c) 2015年 firefly. All rights reserved.
//

#import "CCBCheck.h"

@implementation CCBCheck
-(instancetype)init{
    self = [super init];
    if(self){
        NSLog(@"init CCBCheck");
    }
    return self;
}

- (NSMutableDictionary*)readPlist:(NSString *)plistPath{
    NSMutableDictionary *resultDictionary = [NSMutableDictionary dictionaryWithContentsOfFile:plistPath];
    return resultDictionary;
}

- (void)writePlist:(NSString *)plistPath plistDic:(NSDictionary *)plistDictionary{
    [plistDictionary writeToFile:plistPath atomically:YES];
}

- (NSInteger)addKeyValueToDic:(NSMutableDictionary *)fileMap
                      sameDic:(NSMutableDictionary *)sameFilesMap
                          key:(NSString *)key
                        value:(NSString *)value{
    if([fileMap.allKeys containsObject:key]){
        if([sameFilesMap.allKeys containsObject:key]){
            [[sameFilesMap objectForKey:key] addObject:value];
        }else{
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [array addObject:value];
            [array addObject:[fileMap objectForKey:key]];
            [sameFilesMap setObject:array forKey:key];
        }
        return 0;
    }
    [fileMap setObject:value forKey:key];
    return 0;
}

- (NSMutableDictionary *)getFilePathMapWithDir:(NSString *)resourceDir
                                         error:(NSInteger *)errorCode{
    *errorCode = 0;

    NSFileManager *manager = [NSFileManager defaultManager];
    resourceDir = [resourceDir stringByExpandingTildeInPath];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:resourceDir];
    NSMutableDictionary *fileMap = [NSMutableDictionary dictionaryWithCapacity:10];
    NSString *filename ;
    NSMutableDictionary *sameFilesMap = [NSMutableDictionary dictionaryWithCapacity:10];
    while (filename = [direnum nextObject]) {
        if ([[filename pathExtension] isEqualTo:@"plist"]) {
            NSString *plistPath = [NSString stringWithFormat:@"%@/%@",resourceDir,filename];
            NSMutableDictionary *dic = [self readPlist:plistPath];
            dic = [dic objectForKey:@"frames"];
            if (!dic){
                NSLog(@"[ERROR]: no frames key ,please check \n%@   ",plistPath);
                *errorCode = 1000;
                return NULL;
            }
            for (int i = 0; i<dic.allKeys.count; i++) {
                NSString *path = [NSString stringWithFormat:@"%@/%@/%@",resourceDir.lastPathComponent,filename,dic.allKeys[i]];
                [self addKeyValueToDic:fileMap sameDic:sameFilesMap key:dic.allKeys[i] value:path];
            }
        }else if ([[filename pathExtension] isEqualTo:@"jpg"] ||
                  [[filename pathExtension] isEqualTo:@"png"]) {
            NSString *realPath = [NSString stringWithFormat:@"%@/%@",resourceDir.lastPathComponent,filename];
            [self addKeyValueToDic:fileMap sameDic:sameFilesMap key:filename.pathComponents.lastObject value:realPath];
        }
    }
    if (sameFilesMap.allKeys.count > 0) {
        NSLog(@"[ERROR] : Has same files \n%@",sameFilesMap);
        return NULL;
    }
    return fileMap;
}

- (BOOL)updateCCBDir:(NSString *)ccbDir withResource:(NSDictionary*)resources{
    NSFileManager *manager = [NSFileManager defaultManager];
    ccbDir = [ccbDir stringByExpandingTildeInPath];
    NSDirectoryEnumerator *direnum = [manager enumeratorAtPath:ccbDir];
    NSString *filename ;
    BOOL isOK = YES;
    while (filename = [direnum nextObject]) {
        if ([[filename pathExtension] isEqualTo:@"ccb"]) {
            NSString *ccbPath = [NSString stringWithFormat:@"%@/%@",ccbDir,filename];
            if(![self updateCCB:ccbPath withResource:resources]){
                NSLog(@"[ERROR] : update failed: %@",ccbPath);
                isOK = NO;
                return isOK;
            }
        }
    }
    return isOK;
}

- (BOOL)updateChild:(NSMutableDictionary *)child
           resource:(NSDictionary *)resources{
    // check properties
    NSMutableArray *array = [child objectForKey:@"properties"];
    if(array){
        for (NSMutableDictionary* item in array) {
            NSString *type = [item objectForKey:@"type"];
            if([type isEqualToString:@"SpriteFrame"]){
                NSMutableArray* values = [item objectForKey:@"value"];
                NSString *oldValue1 = [values objectAtIndex:0];
                NSString *oldValue2 = [values objectAtIndex:1];
                
                NSString *spriteName = [oldValue2 lastPathComponent];
                NSString *spritePath = [resources objectForKey:spriteName];
                
                NSString *value1 = @"";
                NSString *value2 = spritePath;
                if([spritePath containsString:@".plist/"]){
                    value1 = [spritePath stringByDeletingLastPathComponent];
                    value2 = spriteName;
                }
                if(!spritePath){
                    NSLog(@"[ERROR]:file not found :  %@  %@ ",oldValue1,oldValue2);
                    value1 = oldValue1;
                    value2 = oldValue2;
                }
                [values removeAllObjects];
                [values addObject:value1];
                [values addObject:value2];
                [item setObject:values forKey:@"value"];
            }
        }
    }
    NSMutableArray *childs = [child objectForKey:@"children"];
    for (NSMutableDictionary*item in childs) {
        [self updateChild:item resource:resources];
    }

    return YES;
}

- (BOOL)updateCCB:(NSString *)ccbFilePath withResource:(NSDictionary*)resources{
    if (![[ccbFilePath pathExtension] isEqualTo:@"ccb"]){
        NSLog(@"[ERROR] : not a ccb file: %@",ccbFilePath);
        return NO;
    }

    NSLog(@"start update : %@",ccbFilePath);
    NSMutableDictionary *dic = [self readPlist:ccbFilePath];
    NSMutableDictionary *nodeGraph = [dic objectForKey:@"nodeGraph"];
    if(!nodeGraph){
        nodeGraph = dic;
    }
//    NSLog(@"%@",resources);
//    NSLog(@"%@",dic);

    if([self updateChild:nodeGraph resource:resources]){
        [self writePlist:ccbFilePath plistDic:dic];
    }
//    NSLog(@"finish update : %@",ccbFilePath);
//     NSLog(@"%@",dic);
    
    return YES;
}
@end
