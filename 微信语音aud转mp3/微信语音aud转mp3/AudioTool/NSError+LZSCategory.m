//
//  NSError+LZSCategory.m
//  wechathook
//
//  Created by licc on 2018/1/25.

//

#import "NSError+LZSCategory.h"

@implementation NSError (YDJCategory)

+ (instancetype)errorWithString:(NSString *)str {
    str = str ? str : @"";
    return [NSError errorWithDomain:str code:-9999 userInfo:nil];
}

@end
