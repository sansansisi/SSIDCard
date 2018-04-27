//
//  SSTesseract.h
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SSTesseract : NSObject

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, readonly) NSString *recognizedText;

- (instancetype)initWithLanguage:(NSString*)language;

- (BOOL)recognize;

@end
