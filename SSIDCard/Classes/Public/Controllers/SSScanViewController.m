//
//  SSScanViewController.m
//  SSIDCard_Example
//
//  Created by 张家铭 on 2018/4/26.
//  Copyright © 2018年 sansansisi. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SSScanViewController.h"
#import "SSIDCardRectView.h"
#import "SSConstants.h"
#import "NSString+SS.h"
#import "SSImageTool.h"
#import "SSOpencvImageTool.h"
#import "SSTesseract.h"
#import "SSIDCard.h"

@interface SSScanViewController () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) UIView *topWhiteView;
@property (nonatomic, strong) UIButton *returnBtn;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *torchBtn;
@property (nonatomic, strong) UIView *bottomWhiteView;
@property (nonatomic, strong) UILabel *addCardLabel;
@property (nonatomic, strong) UILabel *introduceLabel;
@property (nonatomic, strong) UILabel *handInputLabel;
@property (nonatomic, strong) SSIDCardRectView *scanView;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureMetadataOutput *metadataOutput;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureDevice *device;
@property (nonatomic, strong) NSNumber *outPutSetting;
@property (nonatomic, strong) AVCaptureConnection *connection;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, copy) recognizeBlock block;

@end

@implementation SSScanViewController

#pragma mark - Lify Cycle

- (instancetype)initWithBlock:(recognizeBlock)recognizeBlock {
	if (self = [super init]) {
		self.block = recognizeBlock;
	}
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[self.view.layer addSublayer:self.previewLayer];
	
	[self.view addSubview:self.topWhiteView];
	[self.topWhiteView addSubview:self.returnBtn];
	[self.topWhiteView addSubview:self.titleLabel];
	[self.topWhiteView addSubview:self.torchBtn];
	
	[self.view addSubview:self.bottomWhiteView];
	[self.bottomWhiteView addSubview:self.addCardLabel];
	[self.bottomWhiteView addSubview:self.introduceLabel];
	[self.bottomWhiteView addSubview:self.handInputLabel];
	
	[self.view addSubview:self.scanView];
	self.metadataOutput.rectOfInterest = [self.previewLayer metadataOutputRectOfInterestForRect:self.scanView.frame];
	
	[self configConnection];
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)),
				   dispatch_get_main_queue(), ^{
		[self takePhoto];
	});
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	dispatch_async(self.queue, ^{
		[self.session startRunning];
	});
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
	
	[self.scanView stopScanning];
	
	[self.timer invalidate];
	self.timer = nil;
	
	dispatch_async(self.queue, ^{
		[self.session stopRunning];
	});
}

#pragma mark - <AVCaptureMetadataOutputObjectsDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
	if (metadataObjects.count > 0) {
		AVMetadataMachineReadableCodeObject *metadataObject = metadataObjects.firstObject;
		
		if ([metadataObject.type isEqualToString:AVMetadataObjectTypeFace]) {
			if (!self.videoDataOutput.sampleBufferDelegate) {
				[self.metadataOutput setMetadataObjectsDelegate:nil queue:self.queue];
				[self.videoDataOutput setSampleBufferDelegate:self queue:self.queue];
			}
		}
	}
}

#pragma mark - <AVCaptureVideoDataOutputSampleBufferDelegate>
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection  {
	if ([self.outPutSetting isEqualToNumber:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]]) {
		if (captureOutput == self.videoDataOutput) {
			__block UIImage *image = [SSImageTool ss_imageWithSampleBuffer:sampleBuffer];
			
			CGFloat ratio = SS_CAPTURESESSIONWIDTH / ss_viewWidth();
			dispatch_async(dispatch_get_main_queue(), ^{
				image = [SSImageTool ss_imageWithImage:image inRect:CGRectMake(self.scanView.ss_left * ratio, self.scanView.ss_top * ratio, self.scanView.ss_width * ratio, self.scanView.ss_height * ratio)];
			});

			if (self.videoDataOutput.sampleBufferDelegate) {
				[self.videoDataOutput setSampleBufferDelegate:nil queue:self.queue];
			}
			
			[self recognizeWithImage:image];
		}
	}
}

#pragma mark - Private Method
- (void)configConnection {
	if (self.connection.supportsVideoStabilization) {
		self.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
		self.connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
	}
}

- (void)takePhoto {
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		[self.metadataOutput setMetadataObjectsDelegate:self queue:self.queue];
	});
}

- (void)recognizeWithImage:(UIImage *)image {
	UIImage *recognizeImage = [SSOpencvImageTool ss_obtainIDNumberImage:image];
	BOOL continueTakePhotoFlag = YES;
	if (recognizeImage.size.width > 0) {
		SSTesseract *tesseract = [[SSTesseract alloc] init];
		tesseract.image = recognizeImage;
		[tesseract recognize];
		if (tesseract.recognize) {
			NSString *IDtext = [NSString ss_removeSpaceAndNewline:tesseract.recognizedText];
			if (isIdentityCardNumber(IDtext)) {
				continueTakePhotoFlag = NO;
				dispatch_async(dispatch_get_main_queue(), ^{
					if (self.delegate && [self.delegate respondsToSelector:@selector(ss_scanViewController:didObtainedRecognizeResult:)]) {
						[self.delegate ss_scanViewController:self didObtainedRecognizeResult:IDtext];
					} else if (self.block) {
						self.block(IDtext);
					}
					[self dismissViewControllerAnimated:YES completion:nil];
				});
			}
		}
	}
	
	if (continueTakePhotoFlag) {
		[self takePhoto];
	}
}

int identityCardValidateCode(NSString *cardNumber) {
	if (cardNumber.length != 17) {return 0;}
	NSInteger weight[] = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2}; //十七位数字本体码权重
	char validate[] = {'1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2'};  //mod11,对应校验码字符值
	
	NSInteger sum = 0;
	for (int i = 0; i < cardNumber.length; ++i) {
		NSInteger value = [[cardNumber substringWithRange:NSMakeRange(i, 1)] integerValue];
		sum = sum + value * weight[i];
	}
	int mode = sum % 11;
	return validate[mode];
}

BOOL isIdentityCardNumber(NSString *cardNumber) {
	if (cardNumber.length != 18) {return NO;}
	char validateCode = identityCardValidateCode([cardNumber substringWithRange:NSMakeRange(0, 17)]);
	NSString *validateCodeStr = [NSString stringWithFormat:@"%c", validateCode];
	NSString *lastCode = [cardNumber substringFromIndex:17];
	return [lastCode compare:validateCodeStr options:NSCaseInsensitiveSearch] == NSOrderedSame;
}

#pragma mark - Event Respond
- (void)onReturnBtnClicked {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onTorchBtnClicked {
	self.torchBtn.selected = !_torchBtn.selected;
	if ([self.device hasTorch] && [self.device hasFlash]) {
		[self.device lockForConfiguration:nil];
		if (_torchBtn.selected) {
			[self.device setTorchMode:AVCaptureTorchModeOn];
		} else {
			[self.device setTorchMode:AVCaptureTorchModeOff];
		}
		[self.device unlockForConfiguration];
	} else {
		UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"您的设备没有闪光设备，不能提供手电筒功能" preferredStyle:UIAlertControllerStyleAlert];
		
		UIAlertAction *actionAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
			self.torchBtn.selected = !_torchBtn.selected;
			[alert dismissViewControllerAnimated:YES completion:nil];
		}];
		[alert addAction:actionAction];
		[self presentViewController:alert animated:YES completion:nil];
	}
}

- (void)onHandInputClicked {
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Getters and Setters
- (NSNumber *)outPutSetting {
	if (_outPutSetting == nil) {
		_outPutSetting = @(kCVPixelFormatType_32BGRA);
	}
	return _outPutSetting;
}

- (SSIDCardRectView *)scanView {
	if (!_scanView) {
		CGFloat binkCardRatio = SS_IDCARDHEIGTHWIDTHRATIO;
		CGFloat binkCardWidth = SS_IDWIDTH * ss_viewRatio320();
		CGFloat binkCardHeight = binkCardWidth * binkCardRatio;
		_scanView = [[SSIDCardRectView alloc] initWithFrame:CGRectMake((ss_viewWidth() - binkCardWidth) * 0.5, (ss_viewHeight() - ss_navigationBottom() - _bottomWhiteView.ss_height - binkCardHeight) * 0.5 + ss_navigationBottom(), binkCardWidth, binkCardHeight)];
		
	}
	return _scanView;
}

- (UIButton *)torchBtn {
	if (!_torchBtn) {
		_torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_torchBtn.frame = CGRectMake(ss_viewWidth() - 10 - 40, ss_statusBarHeight() + 2, 40, 40);
		[_torchBtn setImage:[UIImage imageNamed:@"ssidcard_torch.tiff" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[SSIDCard class]] pathForResource:[NSString stringWithFormat:@"%@", [SSIDCard class]] ofType:@"bundle"]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
		UITapGestureRecognizer *tapReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTorchBtnClicked)];
		[_torchBtn addGestureRecognizer:tapReco];
	}
	return _torchBtn;
}

- (UILabel *)titleLabel {
	if (!_titleLabel) {
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ss_statusBarHeight(), 100, ss_navigationBarHeight())];
		_titleLabel.text = @"扫描身份证";
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.ss_centerX = ss_viewWidth() * 0.5;
		_titleLabel.textColor = [UIColor grayColor];
	}
	return _titleLabel;
}

- (UIButton *)returnBtn {
	if (!_returnBtn) {
		_returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
		_returnBtn.frame = CGRectMake(10, ss_statusBarHeight() + 2, 40, 40);		
		[_returnBtn setImage:[UIImage imageNamed:@"ssidcard_navi_orange.tiff" inBundle:[NSBundle bundleWithPath:[[NSBundle bundleForClass:[SSIDCard class]] pathForResource:[NSString stringWithFormat:@"%@", [SSIDCard class]] ofType:@"bundle"]] compatibleWithTraitCollection:nil] forState:UIControlStateNormal];
		UITapGestureRecognizer *tapReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onReturnBtnClicked)];
		[_returnBtn addGestureRecognizer:tapReco];
	}
	return _returnBtn;
}

- (UIView *)topWhiteView {
	if (!_topWhiteView) {
		_topWhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ss_viewWidth(), ss_statusBarHeight() + ss_navigationBarHeight())];
		_topWhiteView.backgroundColor = [UIColor whiteColor];
	}
	return _topWhiteView;
}

- (UIView *)bottomWhiteView {
	if (!_bottomWhiteView) {
		_bottomWhiteView = [[UIView alloc] initWithFrame:CGRectMake(0, ss_viewHeight() - 177, ss_viewWidth(), 177)];
		_bottomWhiteView.backgroundColor = [UIColor whiteColor];
	}
	return _bottomWhiteView;
}

- (UILabel *)addCardLabel {
	if (!_addCardLabel) {
		_addCardLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, ss_viewWidth(), 33)];
		_addCardLabel.text = @"添加身份证";
		_addCardLabel.textAlignment = NSTextAlignmentCenter;
		_addCardLabel.textColor = [UIColor orangeColor];
		_addCardLabel.font = [UIFont systemFontOfSize:24];
	}
	return _addCardLabel;
}

- (UILabel *)introduceLabel {
	if (!_introduceLabel) {
		_introduceLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _addCardLabel.ss_top + _addCardLabel.ss_height + 4, ss_viewWidth(), 20)];
		_introduceLabel.font = [UIFont systemFontOfSize:14];
		_introduceLabel.textColor = [UIColor grayColor];
		_introduceLabel.text = @"请将身份证正面置于上方大方框内";
		_introduceLabel.textAlignment = NSTextAlignmentCenter;
	}
	return _introduceLabel;
}

- (UILabel *)handInputLabel {
	if (!_handInputLabel) {
		_handInputLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, _introduceLabel.ss_height + _introduceLabel.ss_top + 45, ss_viewWidth(), 20)];
		_handInputLabel.font = [UIFont systemFontOfSize:14];
		_handInputLabel.textColor = [UIColor orangeColor];
		_handInputLabel.text = @"手动输入";
		_handInputLabel.textAlignment = NSTextAlignmentCenter;
		_handInputLabel.userInteractionEnabled = YES;
		
		UITapGestureRecognizer *tapReco = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onHandInputClicked)];
		[_handInputLabel addGestureRecognizer:tapReco];
	}
	return _handInputLabel;
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
	if (!_previewLayer) {
		_previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
		CGFloat imageWidthRatioToHeight = SS_CAPTURESESSIONWIDTH / SS_CAPTURESESSIONHEIGHT;
		CGFloat height = ss_viewWidth() / imageWidthRatioToHeight;
		_previewLayer.frame = CGRectMake(0, 0, ss_viewWidth(), height);
		_previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
	}
	return _previewLayer;
}

- (AVCaptureSession *)session {
	if (_session == nil) {
		_session = [[AVCaptureSession alloc] init];
		_session.sessionPreset = AVCaptureSessionPreset1920x1080;
		
		NSError *error = nil;
		AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:&error];
		if (error) {
			NSLog(@"%@", error);
		} else {
			if ([_session canAddInput:input]) {
				[_session addInput:input];
			}
			
			if ([_session canAddOutput:self.videoDataOutput]) {
				[_session addOutput:self.videoDataOutput];
			}
			
			if ([_session canAddOutput:self.metadataOutput]) {
				[_session addOutput:self.metadataOutput];
				self.metadataOutput.metadataObjectTypes = @[ AVMetadataObjectTypeFace ];
			}
		}
	}
	return _session;
}

- (AVCaptureMetadataOutput *)metadataOutput {
	if (!_metadataOutput) {
		_metadataOutput = [[AVCaptureMetadataOutput alloc] init];
	}
	return _metadataOutput;
}

- (dispatch_queue_t)queue {
	if (!_queue) {
		_queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
	}
	return _queue;
}

- (AVCaptureVideoDataOutput *)videoDataOutput {
	if (_videoDataOutput == nil) {
		_videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
		_videoDataOutput.alwaysDiscardsLateVideoFrames = YES;
		_videoDataOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : self.outPutSetting};
	}
	return _videoDataOutput;
}

- (AVCaptureDevice *)device {
	if (_device == nil) {
		_device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
		NSError *error = nil;
		if ([_device lockForConfiguration:&error]) {
			if ([_device isSmoothAutoFocusSupported]) {
				_device.smoothAutoFocusEnabled = YES;
			}
			
			if ([_device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
				_device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
			}
			
			if ([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure ]) {
				_device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
			}
			
			if ([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance]) {
				_device.whiteBalanceMode = AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance;
			}
			[_device unlockForConfiguration];
		}
	}
	
	return _device;
}

- (AVCaptureConnection *)connection {
	if (!_connection) {
		_connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
	}
	return _connection;
}

@end
