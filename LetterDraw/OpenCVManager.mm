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

-(NSString *) openCVVersionString
{
    return [NSString stringWithFormat:@"OpenCV Version %s", CV_VERSION];
}

- (NSDictionary *)boundingRectFor:(UIImage *)image
{
    Mat img;
    UIImageToMat(image, img);
    
    Mat canny_output;
    Canny( img, canny_output, 0, 100, 3 );
    vector<vector<cv::Point> > contours;
    findContours( canny_output, contours, RETR_TREE, CHAIN_APPROX_SIMPLE );
    
    vector<vector<cv::Point> > contours_poly( contours.size() );
    vector<cv::Rect> boundRect( contours.size() );
    
    for( size_t i = 0; i < contours.size(); i++ )
    {
        approxPolyDP( contours[i], contours_poly[i], 3, true );
        boundRect[i] = boundingRect( contours_poly[i] );
    }
    
    float minX = 0; float minY = 0; float maxY = 0; float maxX = 0;
    
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    
    for( size_t i = 0; i< contours.size(); i++ )
    {
        cv::Rect rect = boundRect[i];
        cv::Point tl = rect.tl();
        cv::Point br = rect.br();
        
        if (tl.x < minX || minX == 0) { minX = tl.x; }
        if (tl.y < minY || minY == 0) { minY = tl.y; }
        if (br.y > maxY || maxY == 0) { maxY = br.y; }
        if (br.x > maxX || maxX == 0) { maxX = br.x; }
    }
    
    NSDictionary *results = @{ @"minX": [NSNumber numberWithFloat: minX],
                               @"minY": [NSNumber numberWithFloat: minY],
                               @"maxWidth": [NSNumber numberWithFloat: maxX - minX],
                               @"maxHeight": [NSNumber numberWithFloat: maxY - minY] };
    
    return results;
}

@end
