//
//  SSScanViewController.h
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SSScanViewController;
@class SSIDCard;

@protocol SSScanViewControllerDelegate <NSObject>

@required
- (void)ss_scanViewController:(SSScanViewController *)scanViewController didObtainedRecognizeResult:(SSIDCard *)idcard;

@end

typedef void(^recognizeBlock)(SSIDCard *idcard);

@interface SSScanViewController : UIViewController

@property (nonatomic, weak) id <SSScanViewControllerDelegate> delegate;

- (instancetype)initWithBlock:(recognizeBlock)recognizeBlock;

@end
