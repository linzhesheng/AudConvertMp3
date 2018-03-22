//
//  PCMEncoder.h
//  audtomp3
//
//  Created by licc on 2018/1/30.

//

#import <Foundation/Foundation.h>

@interface PCMEncoder : NSObject

#pragma mark - pcm转化为mp3，返回0表示成功
- (int)convertPcmToMp3WithPcmPath:(NSString *)pcmPath mp3Path:(NSString *)mp3Path;

@end
