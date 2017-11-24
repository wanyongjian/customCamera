//
//  FilterController.m
//  customCamera
//
//  Created by wanyongjian on 2017/11/17.
//  Copyright © 2017年 eco. All rights reserved.
//

#import "FilterController.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/imgproc/types_c.h>

@interface FilterController ()

@end

@implementation FilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 300, 300)];
    [self.view addSubview:imageView];

    cv::Mat cvImage;
    UIImage *image = [UIImage imageNamed:@"water"];
    UIImageToMat(image, cvImage);
    
    if(!cvImage.empty()){
        cv::Mat gray;
        // 将图像转换为灰度显示
        cv::cvtColor(cvImage,gray,CV_RGB2GRAY);
        // 应用高斯滤波器去除小的边缘
        cv::GaussianBlur(gray, gray, cv::Size(5,5), 1.2,1.2);
        // 计算与画布边缘
        cv::Mat edges;
        cv::Canny(gray, edges, 0, 50);
        // 使用白色填充
        cvImage.setTo(cv::Scalar::all(225));
        // 修改边缘颜色
        cvImage.setTo(cv::Scalar(0,128,255,255),edges);
        // 将Mat转换为Xcode的UIImageView显示
        imageView.image = MatToUIImage(cvImage);
    }
}

@end
