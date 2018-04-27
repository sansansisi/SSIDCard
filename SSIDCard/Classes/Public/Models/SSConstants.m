//
//  SSConstants.m
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import "SSConstants.h"

@implementation SSConstants

CGFloat ss_viewWidth() {
	static CGFloat viewWidth = 0;
	if (viewWidth == 0) {
		viewWidth = [UIScreen mainScreen].bounds.size.width;
	}
	
	return viewWidth;
}

CGFloat ss_viewHeight() {
	static CGFloat viewHeight = 0;
	if (viewHeight == 0) {
		viewHeight = [UIScreen mainScreen].bounds.size.height;
	}
	
	return viewHeight;
}

CGFloat ss_viewRatio320(){
	static CGFloat viewRatio320 = 0;
	if (viewRatio320 == 0){
		viewRatio320 = ss_viewWidth() / 320;
	}
	return viewRatio320;
}

CGFloat ss_viewRatio375(){
	static CGFloat viewRatio375 = 0;
	if (viewRatio375 == 0){
		viewRatio375 = ss_viewWidth() / 375;
	}
	return viewRatio375;
}

CGFloat ss_statusBarHeight() {
	static CGFloat statusBarHeight = 0.0;
	if (statusBarHeight == 0.0) {
		statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
	}
	return statusBarHeight;
}

CGFloat ss_navigationBarHeight() {
	static CGFloat navigationBarHeight = 0.0;
	if (navigationBarHeight == 0.0) {
		navigationBarHeight = 44.0;
	}
	return navigationBarHeight;
}

CGFloat ss_navigationBottom() {
	return ss_statusBarHeight() + ss_navigationBarHeight();
}

CGFloat ss_iphoneXBottom() {
	return SS_IS_iPhoneX ? 34.0 : 0.0;
}

BOOL ss_isiPhoneX() {
	return SS_IS_iPhoneX;
}


@end
