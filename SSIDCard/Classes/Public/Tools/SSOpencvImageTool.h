//
//  SSOpencvImageTool.h
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#ifdef __cplusplus
#import <opencv2/core.hpp>
#import <opencv2/imgproc.hpp>
#import <opencv2/core/core_c.h>
#import <opencv2/imgcodecs/ios.h>
#endif

#ifdef __ObjC
#import <UIKit/UIKit.h>
#endif

@interface SSOpencvImageTool : NSObject

@property (nonatomic, strong) UIImage *idNumberRectImage;
@property (nonatomic, strong) UIImage *idNameRectImage;

- (void)ss_processImage:(UIImage *)image;

@end
