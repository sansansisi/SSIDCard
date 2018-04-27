//
//  SSScanViewController.h
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSScanViewController;

@protocol SSScanViewControllerDelegate <NSObject>

@required
- (void)ss_scanViewController:(SSScanViewController *)scanViewController didObtainedRecognizeResult:(NSString *)recognizeResult;

@end

typedef void(^recognizeBlock)(NSString *result);

@interface SSScanViewController : UIViewController

@property (nonatomic, weak) id <SSScanViewControllerDelegate> delegate;

- (instancetype)initWithBlock:(recognizeBlock)recognizeBlock;

@end
