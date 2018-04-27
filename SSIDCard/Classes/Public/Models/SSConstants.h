//
//  SSConstants.h
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIView+Frame.h"

#define SS_IDCARDHEIGTHWIDTHRATIO  (54.0 / 85.6)  // 身份证高与宽的比
#define SS_IDWIDTH 290.0 // 身份证的宽
#define SS_CAPTURESESSIONWIDTH 1080.0 // session的宽
#define SS_CAPTURESESSIONHEIGHT 1920.0 // session的高

#define SS_IS_iPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? [[UIScreen mainScreen] currentMode].size.height == 2436 : NO)

@interface SSConstants : NSObject

CGFloat ss_viewWidth(void);
CGFloat ss_viewHeight(void);
CGFloat ss_viewRatio320(void);
CGFloat ss_viewRatio375(void);
CGFloat ss_statusBarHeight(void);
CGFloat ss_navigationBarHeight(void);
CGFloat ss_navigationBottom(void);
CGFloat ss_iphoneXBottom(void);
BOOL ss_isiPhoneX(void);

@end
