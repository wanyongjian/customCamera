//
//  ViewController.m
//  customCamera
//
//  Created by wanyongjian on 2017/11/15.
//  Copyright © 2017年 eco. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController () <AVCapturePhotoCaptureDelegate>

/** 捕获设备，通常是前置摄像头、后置摄像头、麦克风 */
@property (nonatomic, strong) AVCaptureDevice *device;
/** 输入设备，使用AVCaptureDevice来初始化 */
@property (nonatomic, strong) AVCaptureInput *input;
/** 输出图片 */
@property (nonatomic ,strong) AVCapturePhotoOutput *imageOutput;
/** 把输入输出结合到一起，并开始启动捕获设备 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 图像预览层，实时显示捕获的图像 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (nonatomic, strong) UIButton *shotButton;
@end

@implementation ViewController

/** 流程是：获取硬件->初始化输入设备->图像输出->输入输出结合->生成预览层实时图像*/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self cameraDistrict];
    [self.view addSubview:self.shotButton];
}

- (void)cameraDistrict{
    //创建输入设备
    self.device = [self cameraWithPosition:AVCaptureDevicePositionBack];
    //创建输入源
    self.input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    //创建图像输出
    self.imageOutput = [[AVCapturePhotoOutput alloc] init];
    /** 创建会话*/
    self.session = [[AVCaptureSession alloc]init];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
    //连接输入与会话
    if ([self.session canAddInput:self.input]) {
        [self.session addInput:self.input];
    }
    //连接输出与会话
    if ([self.session canAddOutput:self.imageOutput]) {
        [self.session addOutput:self.imageOutput];
    }
    /** 预览画面*/
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.frame;
    [self.view.layer addSublayer:self.previewLayer];
    /** 设备取景开始*/
    [self.session startRunning];
}

/* 获取硬件*/
- (AVCaptureDevice*)cameraWithPosition:(AVCaptureDevicePosition)position{
    AVCaptureDeviceDiscoverySession *devices = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:position];
    
    NSArray *devicesIOS  = devices.devices;
    for (AVCaptureDevice *device in devicesIOS) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
    
}

- (UIButton *)shotButton{
    if (!_shotButton) {
        _shotButton = [[UIButton alloc]init];
        _shotButton.backgroundColor = [UIColor blackColor];
        _shotButton.frame = CGRectMake(kScreenWidth/2, kScreenHeight/2, 60, 60);
        [_shotButton addTarget:self action:@selector(shotAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shotButton;
}

/** 拍照拿到图片 */
- (void)shotAction:(UIButton *)sender{
    
    AVCapturePhotoSettings *settings = [AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
    settings.flashMode = AVCaptureFlashModeOff;
    [self.imageOutput capturePhotoWithSettings:settings delegate:self];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error{
        NSData *imageData = [photo fileDataRepresentation];
        UIImage *image = [UIImage imageWithData:imageData];
        UIImageView *view = [[UIImageView alloc]initWithImage:image];
        view.frame = self.view.frame;
        [self.view addSubview:view];
    [self saveImageToPhotoAlbum:image];
}

/** 保存照片到相册 */
- (void)saveImageToPhotoAlbum:(UIImage *)saveImage{
    UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *) contextInfo

{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
}

/** 切换前后摄像头 */

@end
