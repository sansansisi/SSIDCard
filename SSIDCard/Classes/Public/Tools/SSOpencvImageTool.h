//
//  SSOpencvImageTool.h
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

@interface SSOpencvImageTool : NSObject

@property (nonatomic, strong) UIImage *idNumberRectImage;
@property (nonatomic, strong) UIImage *idNameRectImage;

- (void)ss_processImage:(UIImage *)image;

@end
