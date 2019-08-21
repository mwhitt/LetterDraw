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

int thresh = 100;
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
    Canny( img, canny_output, thresh, thresh*2 );
    vector<vector<cv::Point> > contours;
    findContours( canny_output, contours, RETR_TREE, CHAIN_APPROX_SIMPLE );
    
    vector<vector<cv::Point> > contours_poly( contours.size() );
    vector<cv::Rect> boundRect( contours.size() );
    vector<Point2f>centers( contours.size() );
    vector<float>radius( contours.size() );
    
    for( size_t i = 0; i < contours.size(); i++ )
    {
        approxPolyDP( contours[i], contours_poly[i], 3, true );
        boundRect[i] = boundingRect( contours_poly[i] );
        minEnclosingCircle( contours_poly[i], centers[i], radius[i] );
    }
    
    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
    
    for( size_t i = 0; i< contours.size(); i++ )
    {
        Scalar color = Scalar( rng.uniform(0, 256), rng.uniform(0,256), rng.uniform(0,256) );
        drawContours( drawing, contours_poly, (int)i, color );
        rectangle( drawing, boundRect[i].tl(), boundRect[i].br(), color, 2 );
        circle( drawing, centers[i], (int)radius[i], color, 2 );
    }
    
    UIImage *output = MatToUIImage(drawing);
    NSLog(@"DONE");
    
    // MOCK RETURN VALUES
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    return [[NSDictionary alloc] initWithDictionary:dict];
}

@end
