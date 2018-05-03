//
//  UIView+SS.m
//  SSIDCard
//
//  Created by 张家铭 on 2018/5/3.
//

#import "UIView+SS.h"

@implementation UIView (SS)

- (CGFloat)ss_left {
	return self.frame.origin.x;
}

- (void)setSs_left:(CGFloat)ss_left {
	CGRect frame = self.frame;
	frame.origin.x = ss_left;
	self.frame = frame;
}

- (CGFloat)ss_top {
	return self.frame.origin.y;
}

- (void)setSs_top:(CGFloat)ss_top {
	CGRect frame = self.frame;
	frame.origin.y = ss_top;
	self.frame = frame;
}

- (CGFloat)ss_right {
	return self.frame.origin.x + self.frame.size.width;
}

- (void)setSs_right:(CGFloat)ss_right {
	CGRect frame = self.frame;
	frame.origin.x = ss_right - frame.size.width;
	self.frame = frame;
}

- (CGFloat)ss_bottom {
	return self.frame.origin.y + self.frame.size.height;
}

- (void)setSs_bottom:(CGFloat)ss_bottom {
	CGRect frame = self.frame;
	frame.origin.y = ss_bottom - frame.size.height;
	self.frame = frame;
}

- (CGFloat)ss_width {
	return self.frame.size.width;
}

- (void)setSs_width:(CGFloat)ss_width {
	CGRect frame = self.frame;
	frame.size.width = ss_width;
	self.frame = frame;
}

- (CGFloat)ss_height {
	return self.frame.size.height;
}

- (void)setSs_height:(CGFloat)ss_height {
	CGRect frame = self.frame;
	frame.size.height = ss_height;
	self.frame = frame;
}

- (CGFloat)ss_centerX {
	return self.center.x;
}

- (void)setSs_centerX:(CGFloat)ss_centerX {
	self.center = CGPointMake(ss_centerX, self.center.y);
}

- (CGFloat)ss_centerY {
	return self.center.y;
}

- (void)setSs_centerY:(CGFloat)ss_centerY {
	self.center = CGPointMake(self.center.x, ss_centerY);
}

- (CGPoint)ss_origin {
	return self.frame.origin;
}

- (void)setSs_origin:(CGPoint)ss_origin {
	CGRect frame = self.frame;
	frame.origin = ss_origin;
	self.frame = frame;
}

- (CGSize)ss_size {
	return self.frame.size;
}

- (void)setSs_size:(CGSize)ss_size {
	CGRect frame = self.frame;
	frame.size = ss_size;
	self.frame = frame;
}

@end
