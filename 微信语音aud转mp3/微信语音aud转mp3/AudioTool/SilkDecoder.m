//
//  SilkDecoder.m
//  audtomp3
//
//  Created by licc on 2018/1/30.

//

#import "SilkDecoder.h"
#import "SKP_Silk_SDK_API.h"

#define MAX_BYTES_PER_FRAME     1024
#define MAX_INPUT_FRAMES        5
#define FRAME_LENGTH_MS         20
#define MAX_API_FS_KHZ          48


@interface SilkDecoder ()
{
    double fileLength;
    size_t counter;
    SKP_int32 ret, tot_len, totPackets;
    SKP_int32 decSizeBytes, frames, packetSize_ms, sampleRate;
    SKP_int16 nBytes, len;
    SKP_uint8 payload[MAX_BYTES_PER_FRAME * MAX_INPUT_FRAMES], *payloadToDec;
    SKP_int16 out[((FRAME_LENGTH_MS * MAX_API_FS_KHZ) << 1) * MAX_INPUT_FRAMES], *outPtr;
    void *psDec;
    FILE *inFile, *outFile;
    SKP_SILK_SDK_DecControlStruct DecControl;
    const char *bitInFileName;
    const char *speechOutFileName;
}

@end

@implementation SilkDecoder

- (int)convertSilkToPcmWithSilkPath:(NSString *)silkPath pcmPath:(NSString *)pcmPath {
    //得到输入文件和输出文件的路径
    bitInFileName = [silkPath cStringUsingEncoding:NSASCIIStringEncoding];
    speechOutFileName = [pcmPath cStringUsingEncoding:NSASCIIStringEncoding];
    //打开输入文件
    inFile = fopen(bitInFileName, "rb");
    if( inFile == NULL ) {
        printf( "Error: could not open input file %s\n", bitInFileName );
        return -999;
    }
    //验证文件头
    {
        char header_buf[50];
        fread(header_buf, sizeof(char), strlen("#!SILK_V3"), inFile);
        header_buf[strlen("#!SILK_V3")] = '\0';
        if (strcmp(header_buf, "#!SILK_V3") != 0) {
            printf( "Error: Wrong Header %s\n", header_buf );
            return -999;
        }
//        printf( "Header is %s\n", header_buf );
    }
    // 打开输出文件
    outFile = fopen(speechOutFileName, "wb");
    if (outFile == NULL) {
        printf( "Error: could not open output file %s\n", speechOutFileName );
        return -999;
    }
    // 设置采样率
    if (sampleRate == 0) {
        DecControl.API_sampleRate = 24000;
    } else {
        DecControl.API_sampleRate = sampleRate;
    }
    // 获取 Silk 解码器状态的字节大小
    ret = SKP_Silk_SDK_Get_Decoder_Size(&decSizeBytes);
    if (ret) {
        printf( "\nSKP_Silk_SDK_Get_Decoder_Size returned %d", ret );
    }
    psDec = malloc((size_t) decSizeBytes);
    // 初始化解码器
    ret = SKP_Silk_SDK_InitDecoder(psDec);
    if( ret ) {
        printf( "\nSKP_Silk_InitDecoder returned %d", ret );
    }
    
    totPackets = 0;
    
    while (1) {
        // 读取有效数据大小
        counter = fread(&nBytes, sizeof(SKP_int16), 1, inFile);
        if (nBytes < 0 || counter < 1) {
            break;
        }
        // 读取有效数据
        counter = fread(payload, sizeof(SKP_uint8), (size_t) nBytes, inFile);
        if ((SKP_int16) counter < nBytes) {
            break;
        }
        
        payloadToDec = payload;
        
        outPtr = out;
        tot_len = 0;
        
        frames = 0;
        do {
            // 解码
            ret = SKP_Silk_SDK_Decode(psDec, &DecControl, 0, payloadToDec, nBytes, outPtr, &len);
            if( ret ) {
                printf( "\nSKP_Silk_SDK_Decode returned %d", ret );
            }
            
            frames++;
            outPtr += len;
            tot_len += len;
            if (frames > MAX_INPUT_FRAMES) {
                outPtr = out;
                tot_len = 0;
                frames = 0;
            }
        } while (DecControl.moreInternalDecoderFrames);
        
        packetSize_ms = tot_len / (DecControl.API_sampleRate / 1000);
        totPackets++;
        // 将解码后的数据保存到文件
        fwrite(out, sizeof(SKP_int16), (size_t) tot_len, outFile);
    }
    
//    printf("\nPackets decoded:%d",totPackets);
//    printf("\nDecoding Finished");
    
    free(psDec);
    
    fclose(outFile);
    fclose(inFile);
    
    fileLength = totPackets * 1e-3 * packetSize_ms;
//    printf("\nFile length:%.3f s",fileLength);
    
    return 0;
}

@end
