//
//  SSImageTool.h
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface SSImageTool : NSObject

/**
 *  将CMSampleBufferRef转成UIImage对象
 
 *  @param sampleBuffer sampleBuffer
 *  @return image
 */
+ (UIImage *)ss_imageWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 *  根据rect裁剪图片
 
 *  @param image image
 *  @param rect rect
 *  @return image
 */
+ (UIImage *)ss_imageWithImage:(UIImage *)image inRect:(CGRect)rect;

@end
