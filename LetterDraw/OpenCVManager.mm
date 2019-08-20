//
//  OpenCVManager.m
//  LetterDraw
//
//  Created by Matthew Whittaker on 8/20/19.
//  Copyright © 2019 One Stream Ventures. All rights reserved.
//
#ifdef __cplusplus
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdocumentation"

#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVManager.h"

#pragma clang pop
#endif

using namespace cv;
using namespace std;

@implementation OpenCVManager
{
    cv::Mat gtpl;
}

-(NSString *) openCVVersionString
{
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

// Inspired by: https://stackoverflow.com/questions/23506105/extracting-text-opencv

- (NSDictionary *)boundingRectFor:(UIImage *)image
{
    cv::Mat tpl;
    UIImageToMat(image, tpl);
    // morphological gradient
    cv::Mat grad;
    Mat morphKernel = cv::getStructuringElement(MORPH_ELLIPSE, cv::Size(3,3));
    cv::morphologyEx(tpl, grad, MORPH_GRADIENT, morphKernel);
    // binarize
    cv::Mat bw;
    cv::threshold(grad, bw, 0.0, 255.0, THRESH_BINARY | THRESH_OTSU);
    // connect horizontally oriented regions
    cv::Mat connected;
    morphKernel = getStructuringElement(MORPH_RECT, cv::Size(9, 1));
    cv::morphologyEx(bw, connected, MORPH_CLOSE, morphKernel);
    // find contours
    cv::Mat mask = Mat::zeros(bw.size(), CV_8UC1);
    vector<vector<cv::Point>> contours;
    vector<Vec4i> hierarchy;
    cv::findContours(connected, contours, hierarchy, RETR_CCOMP, CHAIN_APPROX_SIMPLE, cv::Point(0, 0));
    // filter contours
    for(int idx = 0; idx >= 0; idx = hierarchy[idx][0])
    {
        cv::Rect rect = boundingRect(contours[idx]);
        NSLog(@"%d", rect.width);
    }
    
    // MOCK RETURN VALUES
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    return [[NSDictionary alloc] initWithDictionary:dict];
}

@end
