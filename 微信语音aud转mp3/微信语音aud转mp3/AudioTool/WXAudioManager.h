//
//  WXAudioManager.h
//  audtomp3
//
//  Created by licc on 2018/1/30.
//

#import <Foundation/Foundation.h>

@interface WXAudioManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark - 将aud转化为mp3，耗时操作
/*
 audPath:aud文件路径
 mp3Path:转化后mp3文件的存放路径
 */
- (NSError *)convertAudToMp3WithAudPath:(NSString *)audPath mp3Path:(NSString *)mp3Path;

@end
