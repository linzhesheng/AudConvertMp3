//
//  SilkDecoder.h
//  audtomp3
//
//  Created by licc on 2018/1/30.

//

#import <Foundation/Foundation.h>

@interface SilkDecoder : NSObject

#pragma mark - silk_v3转化为pcm，返回0表示成功
- (int)convertSilkToPcmWithSilkPath:(NSString *)silkPath pcmPath:(NSString *)pcmPath;

@end
