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
@property (nonatomic, strong) AVCaptureDeviceInput *input;
/** 输出图片 */
@property (nonatomic ,strong) AVCapturePhotoOutput *imageOutput;
/** 把输入输出结合到一起，并开始启动捕获设备 */
@property (nonatomic, strong) AVCaptureSession *session;
/** 图像预览层，实时显示捕获的图像 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
/** 摄像头方向*/
@property (nonatomic, assign) AVCaptureDevicePosition position;
@property (nonatomic, assign) AVCaptureFlashMode flashMode;
@property (nonatomic, strong) AVCapturePhotoSettings *settings;
@property (nonatomic, strong) UIButton *shotButton;
@property (nonatomic, strong) UIButton *switchButton;
@property (nonatomic, strong) UIButton *lightButton;
@end

@implementation ViewController

/** 流程是：获取硬件->初始化输入设备->图像输出->输入输出结合->生成预览层实时图像*/
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self cameraDistrict];
    [self.view addSubview:self.shotButton];
    [self.view addSubview:self.switchButton];
    [self.view addSubview:self.lightButton];
    [self layoutSubviews];

}

- (void)layoutSubviews{
    [_shotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view).offset(-50);
        make.width.height.mas_equalTo(80);
    }];
    
    [_switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.view);
        make.left.mas_equalTo(self.view).offset(15);
        make.width.height.mas_equalTo(30);
    }];
    
    [_lightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(_switchButton);
        make.bottom.mas_equalTo(_switchButton.mas_top).offset(-30);
        make.width.height.mas_equalTo(30);
    }];
}
- (void)cameraDistrict{
    //创建输入设备
    self.device = [self cameraWithPosition:self.position];
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

- (UIButton *)lightButton{
    if (!_lightButton) {
        _lightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lightButton setImage:[UIImage imageNamed:@"lightOff"] forState:UIControlStateNormal];
        [_lightButton setImage:[UIImage imageNamed:@"lightOn"] forState:UIControlStateSelected];
        [_lightButton addTarget:self action:@selector(lightAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lightButton;
}
- (UIButton *)switchButton{
    if (!_switchButton) {
        _switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchButton setImage:[UIImage imageNamed:@"switchCamera"] forState:UIControlStateNormal];\
        [_switchButton addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchButton;
}
- (UIButton *)shotButton{
    if (!_shotButton) {
        _shotButton = [[UIButton alloc]init];
        [_shotButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
        [_shotButton addTarget:self action:@selector(shotAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _shotButton;
}

- (AVCaptureDevicePosition)position{
    if (!_position) {
        _position = AVCaptureDevicePositionBack;
    }
    return _position;
}

- (void)switchAction:(UIButton *)sender{
    NSLog(@"转换摄像头");
    AVCaptureDevice *newDevice = nil;
    AVCaptureDeviceInput *newInput = nil;
    self.position = self.input.device.position;
    if (self.position == AVCaptureDevicePositionBack) {
//        self.position = AVCaptureDevicePositionFront;
        newDevice = [self cameraWithPosition:AVCaptureDevicePositionFront];
    }else if (self.position == AVCaptureDevicePositionFront){
//        self.position = AVCaptureDevicePositionBack;
        newDevice = [self cameraWithPosition:AVCaptureDevicePositionBack];
    }
    newInput = [AVCaptureDeviceInput deviceInputWithDevice:newDevice error:nil];
    if (newInput) {
        [self.session beginConfiguration];
        [self.session removeInput:self.input];
        if ([self.session canAddInput:newInput]) {
            [self.session addInput:newInput];
            self.input = newInput;
        }else{
            [self.session addInput:self.input];
        }
        [self.session commitConfiguration];
    }
    
}
- (void)lightAction:(UIButton *)sender{
    // 手电筒功能
//    /**修改前必须线锁定*/
//    [self.device lockForConfiguration:nil];
//    /** 必须判断是否有闪光灯，否则会闪退*/
//    if ([self.device hasFlash]) {
//
//        if (self.device.flashMode == AVCaptureFlashModeOn) {
//            self.lightButton.selected = NO;
//            self.device.flashMode = AVCaptureFlashModeOff;
//            self.device.torchMode = AVCaptureTorchModeOff;
//        }else if(self.device.flashMode == AVCaptureFlashModeOff){
//            self.lightButton.selected = YES;
//            self.device.flashMode = AVCaptureFlashModeOn;
//            self.device.torchMode = AVCaptureTorchModeOn;
//        }
//    }
//
//    [self.device unlockForConfiguration];
    
    //闪光灯功能
    sender.selected = !sender.selected;
    if (sender.selected == YES) {
        self.flashMode = AVCaptureFlashModeOn;
    }else{
        self.flashMode = AVCaptureFlashModeOff;
    }
}

- (AVCaptureFlashMode)flashMode{
    if (!_flashMode) {
        _flashMode = AVCaptureFlashModeOff;
    }
    return _flashMode;
}

- (AVCapturePhotoSettings *)settings{
    if (!_settings) {
        _settings =[AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
        _settings.flashMode = AVCaptureFlashModeOff;
    }
    return _settings;
}
/** 拍照拿到图片 */
- (void)shotAction:(UIButton *)sender{
    self.settings =[AVCapturePhotoSettings photoSettingsWithFormat:@{AVVideoCodecKey:AVVideoCodecTypeJPEG}];
    self.settings.flashMode = self.flashMode;
    [self.imageOutput capturePhotoWithSettings:self.settings delegate:self];
}

- (void)captureOutput:(AVCapturePhotoOutput *)output didFinishProcessingPhoto:(AVCapturePhoto *)photo error:(NSError *)error{
//        NSData *imageData = [photo fileDataRepresentation];
//        UIImage *image = [UIImage imageWithData:imageData];
//        UIImageView *view = [[UIImageView alloc]initWithImage:image];
//        view.frame = self.view.frame;
//        [self.view addSubview:view];
//    [self saveImageToPhotoAlbum:image];
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
