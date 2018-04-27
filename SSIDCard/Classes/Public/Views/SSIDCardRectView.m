//
//  SSIDCardRectView.m
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import "SSIDCardRectView.h"
#import "SSConstants.h"
#import "SSIDCard.h"

@interface SSIDCardRectView ()

@property (nonatomic, strong) UIImageView *whiteborderImageVeiw;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) CGRect faceRect;
@property (nonatomic, strong) NSBundle *bundle;

@end

@implementation SSIDCardRectView

#pragma mark - Life Cycle
- (instancetype)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.backgroundColor = [UIColor clearColor];
		
		self.bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[SSIDCard class]] pathForResource:[NSString stringWithFormat:@"%@", [SSIDCard class]] ofType:@"bundle"]];
		
		// 添加白色的边框
		[self addSubview:self.whiteborderImageVeiw];
		
		CGFloat faceWith = 60 * ss_viewRatio320();
		CGFloat faceHeight = 75 * ss_viewRatio320();
		
		self.faceRect = CGRectMake(self.whiteborderImageVeiw.ss_width - faceWith - (40 * ss_viewRatio320()), self.whiteborderImageVeiw.ss_top + (30 * ss_viewRatio320()), faceWith, faceHeight);
		
		// 头像
		UIImageView *profileImgeView = [[UIImageView alloc] initWithFrame:_faceRect];
		profileImgeView.image = [UIImage imageNamed:@"ssidcard_profile.png" inBundle:self.bundle compatibleWithTraitCollection:nil];
		profileImgeView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:profileImgeView];
		
		// 添加定时器
		[self p_addTimer];
	}
	return self;
}

#pragma mark - Interface
- (void)stopScanning {
	[self.timer invalidate];
	self.timer = nil;
}

#pragma mark - Private Method
- (void)p_addTimer {
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02 target:self selector:@selector(timerFire:) userInfo:nil repeats:YES];
	[self.timer fire];
}

- (void)timerFire:(id)notice {
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	rect = self.bounds;
	
	UIBezierPath *facePath = [UIBezierPath bezierPathWithRect:_faceRect];
	facePath.lineWidth = 1.5;
	[[UIColor whiteColor] set];
	[facePath stroke];
	
	CGContextBeginPath(UIGraphicsGetCurrentContext());
	CGContextSetLineWidth(UIGraphicsGetCurrentContext(), 2);
	CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), 1.0, 0.4, 0.0, 0.8);
	
	static CGFloat moveY = 0;
	static CGFloat distanceY = 0;
	CGPoint p1, p2;
	
	moveY += distanceY;
	if (moveY >= CGRectGetHeight(rect) - 2) {
		moveY = -2;
	} else if (moveY <= 2) {
		distanceY = 2;
	}
	
	p1 = CGPointMake(rect.origin.x, moveY);
	p2 = CGPointMake(rect.origin.x + rect.size.width, moveY);
	
	CGContextMoveToPoint(UIGraphicsGetCurrentContext(), p1.x, p1.y);
	CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), p2.x, p2.y);
	
	CGContextStrokePath(UIGraphicsGetCurrentContext());
}

#pragma mark - Getters and Setters
- (UIImageView *)whiteborderImageVeiw {
	if (!_whiteborderImageVeiw) {
		_whiteborderImageVeiw = [[UIImageView alloc] initWithFrame:self.bounds];
		_whiteborderImageVeiw.image = [UIImage imageNamed:@"ssidcard_rect.tiff" inBundle:self.bundle compatibleWithTraitCollection:nil];
	}
	return _whiteborderImageVeiw;
}

@end
