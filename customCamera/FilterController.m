//
//  FilterController.m
//  customCamera
//
//  Created by wanyongjian on 2017/11/17.
//  Copyright © 2017年 eco. All rights reserved.
//

#import "FilterController.h"

@interface FilterController ()

@end

@implementation FilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    UIImage *image = [UIImage imageNamed:@"water"];
    [imageView setImage:image];
    [self.view addSubview:imageView];
    
    image = [self imageProcessedUsingGPUImage:image];
    [imageView setImage:image];
}

- (UIImage *)imageProcessedUsingGPUImage:(UIImage *)imageToProcess;
{
    
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:imageToProcess];
    GPUImageToonFilter *stillImageFilter = [[GPUImageToonFilter alloc] init];
    
    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];
    
    UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentFramebuffer];
    
    
    return currentFilteredVideoFrame;
}

@end
