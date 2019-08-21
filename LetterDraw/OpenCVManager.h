//
//  OpenCVManager.h
//  LetterDraw
//
//  Created by Matthew Whittaker on 8/20/19.
//  Copyright © 2019 One Stream Ventures. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVManager : NSObject
    - (NSString *)openCVVersionString;
    - (NSDictionary *)boundingRectFor:(UIImage *)image;
@end

NS_ASSUME_NONNULL_END
