//
//  SSImageTool.m
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import "SSImageTool.h"

@implementation SSImageTool

+ (UIImage *)ss_imageWithSampleBuffer:(CMSampleBufferRef)sampleBuffer {
	CVImageBufferRef buffer;
	buffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	
	CVPixelBufferLockBaseAddress(buffer, 0);

	uint8_t *base;
	size_t width, height, bytesPerRow;
	base = CVPixelBufferGetBaseAddress(buffer);
	width = CVPixelBufferGetWidth(buffer);
	height = CVPixelBufferGetHeight(buffer);
	bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);

	CGColorSpaceRef colorSpace;
	CGContextRef cgContext;
	colorSpace = CGColorSpaceCreateDeviceRGB();
	cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);

	CGImageRef cgImage;
	UIImage *image;
	cgImage = CGBitmapContextCreateImage(cgContext);
	image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	CGContextRelease(cgContext);
	
	CVPixelBufferUnlockBaseAddress(buffer, 0);
	
	return image;
}

+ (UIImage *)ss_imageWithImage:(UIImage *)image inRect:(CGRect)rect {
	if (rect.size.width >= image.size.width
		&& rect.size.height >= image.size.height) {
		return image;
	}

	CGImageRef newImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
	UIImage *returnImage = [UIImage imageWithCGImage:newImageRef];
	CGImageRelease(newImageRef);
	return returnImage;
}

@end
