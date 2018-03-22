//
//  ViewController.m
//  微信语音aud转mp3
//
//  Created by licc on 2018/3/22.

//

#import "ViewController.h"
#import "WXAudioManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *audPath = [[NSBundle mainBundle] pathForResource:@"7.aud" ofType:nil];
    NSString *tmpDir = NSTemporaryDirectory();
    NSString *mp3Path = [tmpDir stringByAppendingPathComponent:@"7.mp3"];
    NSError *error = [[WXAudioManager sharedInstance] convertAudToMp3WithAudPath:audPath mp3Path:mp3Path];
    NSLog(@"%@",error);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
