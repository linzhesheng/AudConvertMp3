//
//  WXAudioManager.m
//  audtomp3
//
//  Created by licc on 2018/1/30.

//

#import "WXAudioManager.h"
#import "SilkDecoder.h"
#import "PCMEncoder.h"
#import "NSError+LZSCategory.h"

@interface WXAudioManager ()

@end

@implementation WXAudioManager

+ (instancetype)sharedInstance {
    static WXAudioManager *Instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        Instance = [[WXAudioManager alloc] init];
    });
    return Instance;
}

#pragma mark - 将aud转化为mp3，耗时操作
- (NSError *)convertAudToMp3WithAudPath:(NSString *)audPath mp3Path:(NSString *)mp3Path {
    NSError *error = nil;
    NSData *audData = [NSData dataWithContentsOfFile:audPath];
    if (!audData) {
        return [NSError errorWithString:@"audPath文件无法生成data"];
    }
    if (!mp3Path) {
        return [NSError errorWithString:@"mp3Path是nil"];
    }
    
    //删除开头一个字节，就是silk_v3格式的文件
    NSMutableData *audDataM = [NSMutableData dataWithData:audData];
    [audDataM replaceBytesInRange:NSMakeRange(0, 1) withBytes:NULL length:0];
    
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *silkPath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.silk_v3",[self currentTimeStr]]];
    
    [audDataM.copy writeToFile:silkPath options:NSDataWritingAtomic error:&error];
    if (error) {
        return error;
    }
    //转化为pcm文件
    SilkDecoder *decoder = [SilkDecoder new];
    NSString *pcmPath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pcm",[self currentTimeStr]]];
    int ret = [decoder convertSilkToPcmWithSilkPath:silkPath pcmPath:pcmPath];
    if (ret) {
        [[NSFileManager defaultManager] removeItemAtPath:silkPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];
        NSString *errorStr = [NSString stringWithFormat:@"silk_v3转化为pcm时出错，错误码为%d",ret];
        return [NSError errorWithString:errorStr];
    }

    PCMEncoder *encoder = [PCMEncoder new];
    ret = [encoder convertPcmToMp3WithPcmPath:pcmPath mp3Path:mp3Path];
    if (ret) {
        [[NSFileManager defaultManager] removeItemAtPath:silkPath error:nil];
        [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];
        NSString *errorStr = [NSString stringWithFormat:@"pcm转化为mp3时出错，错误码为%d",ret];
        return [NSError errorWithString:errorStr];
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:silkPath error:nil];
    [[NSFileManager defaultManager] removeItemAtPath:pcmPath error:nil];
    
    return nil;
}

#pragma mark - 获取当前时间戳
- (NSString *)currentTimeStr{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time=[date timeIntervalSince1970]*1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

@end
