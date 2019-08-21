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

RNG rng(12345);

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
    
    double maxX = 0; double maxY = 0;
    double maxWidth = 0; double maxHeight = 0;
    
    for( size_t i = 0; i< contours.size(); i++ )
    {
        cv::Rect rect = boundRect[i];
        if (rect.width > maxWidth) { maxWidth = rect.width; }
        if (rect.height > maxHeight) { maxHeight = rect.height; }
        if (rect.x > maxX) { maxX = rect.x; }
        if (rect.y > maxY) { maxY = rect.y; }
    }
    
    NSDictionary *results = @{ @"maxX": [NSNumber numberWithDouble: maxX],
                               @"maxY": [NSNumber numberWithDouble: maxY],
                               @"maxWidth": [NSNumber numberWithDouble: maxWidth],
                               @"maxHeight": [NSNumber numberWithDouble: maxHeight] };
    
    NSLog(@"** DEBUG: Bounding Rect: %@", results);
    return results;
}

@end
