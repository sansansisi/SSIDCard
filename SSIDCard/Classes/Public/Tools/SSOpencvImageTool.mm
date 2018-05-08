//
//  SSOpencvImageTool.m
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import "SSOpencvImageTool.h"

@implementation SSOpencvImageTool

+ (UIImage *)ss_obtainIDNumberImage:(UIImage *)image {
	cv::Mat srcMat, resultMat;
	srcMat = [self matWithImage:image];
	cv::medianBlur(srcMat, resultMat, 3);
	
	resultMat = adaptiveThereshold(resultMat);
	
	cv::Mat erodeKernel = getStructuringElement(cv::MORPH_CROSS, cv::Size(30,1));
	cv::erode(resultMat, resultMat, erodeKernel, cv::Point(-1, -1), 1);
	
	std::vector<std::vector<cv::Point>> contours;
	cv::findContours(resultMat, contours, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, cvPoint(0, 0));
	cv::Rect numberRect = cv::Rect(0,0,0,0);
	std::vector<std::vector<cv::Point>>::const_iterator itContours = contours.begin();
	for ( ; itContours != contours.end(); ++itContours) {
		cv::Rect rect = cv::boundingRect(*itContours);
		if (rect.x >= numberRect.x && rect.y >= numberRect.y && rect.width > rect.height * 5 && rect.x > 200 && rect.y > 300 && rect.height > 20 && rect.height < 40) {
			numberRect = rect;
		}
	}
	
	// 定位失败
	if (numberRect.width == 0 || numberRect.height == 0) {
		return nil;
	}
	
	// 定位成功
	cv::Mat matImage = [self matWithImage:image];
	resultMat = matImage(numberRect);
	cvtColor(resultMat, resultMat, cv::COLOR_BGR2GRAY);
	cv::threshold(resultMat, resultMat, 0, 255, CV_THRESH_OTSU);
	
	UIImage *numberImage = [self imageWithCVMat:resultMat];
	return numberImage;
}

+ (cv::Mat)matWithImage:(UIImage *)image {
	
	CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
	CGFloat cols = image.size.width;
	CGFloat rows = image.size.height;
	
	cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
	
	CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to backing data
													cols,                      // Width of bitmap
													rows,                     // Height of bitmap
													8,                          // Bits per component
													cvMat.step[0],              // Bytes per row
													colorSpace,                 // Colorspace
													kCGImageAlphaNoneSkipLast |
													kCGBitmapByteOrderDefault); // Bitmap info flags
	
	CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
	CGContextRelease(contextRef);
	
	return cvMat;
}

+ (UIImage *)imageWithCVMat:(const cv::Mat&)cvMat {
	NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize() * cvMat.total()];
	
	CGColorSpaceRef colorSpace;
	
	if (cvMat.elemSize() == 1) {
		colorSpace = CGColorSpaceCreateDeviceGray();
	} else {
		colorSpace = CGColorSpaceCreateDeviceRGB();
	}
	
	CFDataRef dataRef = (__bridge CFDataRef)data;
	CGDataProviderRef provider = CGDataProviderCreateWithCFData(dataRef);
	
	CGImageRef imageRef = CGImageCreate(cvMat.cols,                                     // Width
										cvMat.rows,                                     // Height
										8,                                              // Bits per component
										8 * cvMat.elemSize(),                           // Bits per pixel
										cvMat.step[0],                                  // Bytes per row
										colorSpace,                                     // Colorspace
										kCGImageAlphaNone | kCGBitmapByteOrderDefault,  // Bitmap info flags
										provider,                                       // CGDataProviderRef
										NULL,                                           // Decode
										false,                                          // Should interpolate
										kCGRenderingIntentDefault);                     // Intent
	
	UIImage *image = [[UIImage alloc] initWithCGImage:imageRef];
	CGImageRelease(imageRef);
	CGDataProviderRelease(provider);
	CGColorSpaceRelease(colorSpace);
	
	return image;
}

// 局部自适应快速积分二值化方法 https://blog.csdn.net/realizetheworld/article/details/46971143
cv::Mat adaptiveThereshold(cv::Mat src)
{
	cv::Mat dst;
	cvtColor(src,dst,CV_BGR2GRAY);
	int x1, y1, x2, y2;
	int count=0;
	long long sum=0;
	int S=src.rows>>3;  //划分区域的大小S*S
	int T=15;         /*百分比，用来最后与阈值的比较。原文：If the value of the current pixel is t percent less than this average
					   then it is set to black, otherwise it is set to white.*/
	int W=dst.cols;
	int H=dst.rows;
	long long **Argv;
	Argv=new long long*[dst.rows];
	for(int ii=0;ii<dst.rows;ii++)
	{
		Argv[ii]=new long long[dst.cols];
	}
	
	for(int i=0;i<W;i++)
	{
		sum=0;
		for(int j=0;j<H;j++)
		{
			sum+=dst.at<uchar>(j,i);
			if(i==0)
				Argv[j][i]=sum;
			else
				Argv[j][i]=Argv[j][i-1]+sum;
		}
	}
	
	for(int i=0;i<W;i++)
	{
		for(int j=0;j<H;j++)
		{
			x1=i-S/2;
			x2=i+S/2;
			y1=j-S/2;
			y2=j+S/2;
			if(x1<0)
				x1=0;
			if(x2>=W)
				x2=W-1;
			if(y1<0)
				y1=0;
			if(y2>=H)
				y2=H-1;
			count=(x2-x1)*(y2-y1);
			sum=Argv[y2][x2]-Argv[y1][x2]-Argv[y2][x1]+Argv[y1][x1];
			
			
			if((long long)(dst.at<uchar>(j,i)*count)<(long long)sum*(100-T)/100)
				dst.at<uchar>(j,i)=0;
			else
				dst.at<uchar>(j,i)=255;
		}
	}
	for (int i = 0 ; i < dst.rows; ++i)
	{
		delete [] Argv[i];
	}
	delete [] Argv;
	return dst;
}

@end
