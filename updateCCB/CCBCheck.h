//
//  CCBCheck.h
//  updateCCB
//
//  Created by liulihua on 15/3/22.
//  Copyright (c) 2015年 firefly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCBCheck : NSObject
- (NSMutableDictionary *)getFilePathMapWithDir:(NSString *)resourceDir error:(NSInteger *)errorCode;
- (BOOL)updateCCB:(NSString *)ccbFilePath withResource:(NSDictionary*)resources;
- (BOOL)updateCCBDir:(NSString *)ccbDir withResource:(NSDictionary*)resources;
@end
