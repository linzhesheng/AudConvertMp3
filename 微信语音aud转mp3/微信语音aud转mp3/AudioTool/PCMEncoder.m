//
//  PCMEncoder.m
//  audtomp3
//
//  Created by licc on 2018/1/30.

//

#import "PCMEncoder.h"
#import "lame.h"

@implementation PCMEncoder

- (int)convertPcmToMp3WithPcmPath:(NSString *)pcmPath mp3Path:(NSString *)mp3Path {
    int state = -999;
    @try {
        int read, write;
        
        FILE *pcm = fopen([pcmPath cStringUsingEncoding:NSASCIIStringEncoding], "rb");  //source
        fseek(pcm, 4*1024, SEEK_CUR);                                   //skip file header
        FILE *mp3 = fopen([mp3Path cStringUsingEncoding:NSASCIIStringEncoding], "wb");  //output
        
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init(); // 初始化
        lame_set_num_channels(lame, 2); // 双声道
        lame_set_in_samplerate(lame, 12000); // 12k采样率
        lame_set_brate(lame, 50);  // 压缩的比特率为50
        lame_set_quality(lame, 1);  // mp3音质，很好
        lame_init_params(lame);
        
        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);
            
            fwrite(mp3_buffer, write, 1, mp3);
            
        } while (read != 0);
        
        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
        state = 0;
    }
    @catch (NSException *exception) {
        state = -999;
    }
    @finally {
        return state;
    }
}



@end
